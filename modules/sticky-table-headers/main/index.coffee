import { select, getHexagonElementDataObject } from 'selection/main'
import { mergeDefined, flatten } from 'utils/main'
import { scrollbarSize } from 'dom-utils/main'
import logger from 'logger/main'

# XXX: webpack: how does the resize-events dependency work now?
#      should there be a requirement on it here?
#      should it be made more explicit with something like select.use(resizeEvents()) ?

updateScrollIndicators = (wrapper, top, right, bottom, left) ->
  # Sets the visibility of the scroll indicators (for devices with 0 width scrollbars)
  node = wrapper.node()

  canScrollUp = node.scrollTop > 0
  canScrollDown = node.scrollTop < node.scrollHeight - node.clientHeight
  canScrollLeft = node.scrollLeft > 0
  canScrollRight = node.scrollLeft < node.scrollWidth - node.clientWidth

  top.style('display', if canScrollUp then 'block' else '')
  right.style('display', if canScrollRight then 'block' else '')
  bottom.style('display', if canScrollDown then 'block' else '')
  left.style('display', if canScrollLeft then 'block' else '')

updateHeaderPositions = (container, wrapperNode) ->
  # Set the relative positions of the two headers.
  # This method reduces flickering when scrolling on mobile devices.
  leftOffset = - wrapperNode.scrollLeft
  topOffset = - wrapperNode.scrollTop

  topNode = container.shallowSelect('.hx-sticky-table-header-top')
  if topNode?
    topNode.select('.hx-table').style('left', leftOffset + 'px')

  leftNode = container.shallowSelect('.hx-sticky-table-header-left')
  if leftNode?
    leftNode.select('.hx-table').style('top', topOffset + 'px')

cloneEvents = (elem, clone) ->
  # Copy all events and recurse through children.
  if elem? and clone?
    elemData = getHexagonElementDataObject(elem)
    listenerNamesRegistered = elemData.listenerNamesRegistered?.values()

    if listenerNamesRegistered and listenerNamesRegistered.length > 0
      origEmitter = elemData.eventEmitter

      cloneElem = select(clone)
      for listener in listenerNamesRegistered
        cloneElem.on listener, -> return

      cloneEmitter = getHexagonElementDataObject(clone).eventEmitter
      cloneEmitter.pipe(origEmitter)

    elemChildren = elem.childNodes
    if elemChildren
      cloneChildren = clone.childNodes
      cloneEvents elemChildren[i], cloneChildren[i] for i in [0..elemChildren.length]

getChildrenFromTable = (t, body, single) ->
  realParents = getChildren(t.select(if body then 'tbody' else 'thead'), 'tr')
  flatten realParents.map (parent) -> getChildren(select(parent), 'th, td', single)

getChildren = (parent, selector, single) ->
  children = if single
    parent.select selector
  else
    parent.selectAll selector
  children.filter((node) -> node.node().parentNode is parent.node()).nodes

createStickyHeaderNodes = (real, cloned) ->
  for i in [0...real.length]
    cloneEvents(real[i], cloned[i])

    # The real table shouldn't show the sticky header nodes
    select(real[i]).classed('hx-sticky-table-invisible', true)
    select(cloned[i]).classed('hx-sticky-table-invisible', false)

cloneTableAndNodeEvents = (selection, realTable, tableClone, body, single) ->
  innerTableClone = selection.append(tableClone.clone(true))
  # We make all the cells invisible by default and then only make the ones we care about visible in `createStickyHeaderNodes`
  innerTableClone.selectAll('th, td').classed('hx-sticky-table-invisible', true)
  realNodes = getChildrenFromTable(realTable, body, single)
  clonedNodes = getChildrenFromTable(innerTableClone, body, single)
  createStickyHeaderNodes(realNodes, clonedNodes)
  innerTableClone

class StickyTableHeaders
  constructor: (selector, options) ->

    resolvedOptions = mergeDefined({
      stickTableHead: true # stick thead element
      stickFirstColumn: false # stick first column
      useResponsive: true
      fullWidth: undefined
      containerClass: undefined # Class to add to container to allow styling - useful for situations where table is the root element
    }, options)

    selection = select(selector)
      .api(this)

    table = if selection.classed('hx-table') or selection.node().nodeName.toLowerCase() is 'table'
      tableIsRootElement = true
      selection
    else
      tableIsRootElement = false
      selection.select('.hx-table')

    if table.classed('hx-table-full') and not options.fullWidth?
      options.fullWidth = true

    if resolvedOptions.stickTableHead and table.select('thead').selectAll('tr').empty()
      # Cant stick something that isn't there
      logger.warn 'hx.StickyTableHeaders - ' + selector,
        'Sticky table headers initialized with stickTableHead of true without a thead element present'
      resolvedOptions.stickTableHead = false

    if resolvedOptions.stickFirstColumn and table.select('tbody').select('tr').selectAll('th, td').empty()
      # Cant stick something that isn't there
      logger.warn 'hx.StickyTableHeaders - ' + selector,
        'Sticky table headers initialized with stickFirstColumn of true without any columns to stick'
      resolvedOptions.stickFirstColumn = false

    # Create the container, this will always be the root element.
    container = if tableIsRootElement
      # If the table is the root element, we have to create a div alongside it
      # to allow structuring of the Sticky headers.
      # There's a higher chance of visual issues using this method.
      table.insertAfter('div').class('hx-sticky-table-headers')
    else
      selection.classed('hx-sticky-table-headers', true)

    if resolvedOptions.containerClass
      container.classed(resolvedOptions.containerClass, true)

    # Table wrapper that allows scrolling on the table.
    wrapper = container.append('div').class('hx-sticky-table-wrapper')

    # Put the original table into the wrapper.
    wrapper.append(table)

    showScrollIndicators = scrollbarSize() is 0

    if showScrollIndicators
      # We use four separate divs as using one overlay div prevents click-through
      topIndicator = container.append('div').class('hx-sticky-table-scroll-top')
      rightIndicator = container.append('div').class('hx-sticky-table-scroll-right')
      bottomIndicator = container.append('div').class('hx-sticky-table-scroll-bottom')
      leftIndicator = container.append('div').class('hx-sticky-table-scroll-left')

    # Does all the work of rendering the headers correctly
    wrapper.on 'scroll', 'hx.sticky-table-headers', ->
      if showScrollIndicators
        updateScrollIndicators(wrapper, topIndicator, rightIndicator, bottomIndicator, leftIndicator)
      updateHeaderPositions(container, wrapper.node())

    @_ = {
      options: resolvedOptions,
      container: container,
      wrapper: wrapper,
      table: table,
      selection: selection,
      showScrollIndicators: showScrollIndicators
    }

    @render()

    if resolvedOptions.useResponsive
      self = this
      container.on 'resize', 'hx.sticky-table-headers', ->
        self.render()
        setTimeout (-> self.render()), 100

  render: ->
    _ = @_
    container = _.container
    wrapper = _.wrapper
    wrapperNode = wrapper.node()
    table = _.table
    options = _.options

    origScroll = wrapperNode.scrollTop

    container
      .style('height', undefined)
      .style('width', undefined)

    wrapper
      .style('height', undefined)
      .style('width', undefined)
      .style('margin-top', undefined)
      .style('margin-left', undefined)
      .style('max-width', undefined)
      .style('max-height', undefined)

    table
      .style('margin-top', undefined)
      .style('margin-left', undefined)
      .style('min-width', undefined)
      .style('min-height', undefined)

    offsetHeight = 0
    offsetWidth = 0

    if options.fullWidth
      table.style('width', '100%')

    if options.stickTableHead
      offsetHeight = table.select('thead').height()

    if options.stickFirstColumn
      offsetWidthElem = select(table.select('tbody').select('tr').select('th, td').nodes[0])
      offsetWidth = offsetWidthElem.width()

    totalHeight = container.style('height').replace('px','') - offsetHeight
    totalWidth = container.style('width').replace('px','') - offsetWidth

    wrapper
      .style('width', totalWidth  + 'px')
      .style('height', totalHeight + 'px')
      .style('margin-top', offsetHeight + 'px')
      .style('margin-left', offsetWidth + 'px')

    # resize and reposition stuff

    table
      .style('margin-top', - offsetHeight + 'px')
      .style('margin-left', - offsetWidth + 'px')

    tableBox = table.box()

    hasVerticalScroll = wrapperNode.scrollHeight > wrapperNode.clientHeight
    hasHorizontalScroll = wrapperNode.scrollWidth > wrapperNode.clientWidth
    heightScrollbarOffset = if hasHorizontalScroll then scrollbarSize() else 0
    widthScrollbarOffset = if hasVerticalScroll then scrollbarSize() else 0

    wrapperBox = wrapper.box()

    if options.fullWidth
      table
        .style('width', undefined)
        .style('min-width', wrapperBox.width + offsetWidth - widthScrollbarOffset - 1 + 'px')
    else
      wrapper
        .style('max-width', tableBox.width - offsetWidth + widthScrollbarOffset + 'px')
        .style('max-height', tableBox.height - offsetHeight + heightScrollbarOffset + 'px')

    tableClone = table.clone(true)
      .style('height', table.style('height'))
      .style('width', table.style('width'))

    if options.stickTableHead
      # Append top
      topHead = container.shallowSelect('.hx-sticky-table-header-top')
      if topHead.empty()
        topHead = container.prepend('div').class('hx-sticky-table-header-top')
        # We don't need to do this when the scrollbar size is 0 as there's no empty space shown
        # at the end of each sticky header when scrolling to the bottom right corner of a table.
        if not _.showScrollIndicators and options.fullWidth
          background = table.select('th').style('background-color')
          topHead.style('background-color', background)

      topHead.clear()
      topTable = cloneTableAndNodeEvents topHead, table, tableClone

    if options.stickFirstColumn
      # Append left
      leftHead = container.shallowSelect('.hx-sticky-table-header-left')
      if leftHead.empty()
        leftHead = container.prepend('div').class('hx-sticky-table-header-left')

        if not _.showScrollIndicators and options.fullWidth
          background = table.select('th').style('background-color')
          leftHead.style('background-color', background)

      leftHead.clear()
      leftTable = cloneTableAndNodeEvents leftHead, table, tableClone, true, true

    if options.stickTableHead and options.stickFirstColumn
      # Append top left
      topLeftHead = container.shallowSelect('.hx-sticky-table-header-top-left')
      if topLeftHead.empty()
        topLeftHead = container.prepend('div').class('hx-sticky-table-header-top-left')

      topLeftHead.clear()
      topLeftTable = cloneTableAndNodeEvents topLeftHead, table, tableClone, false, true

    topHead?.style('height', offsetHeight + 'px')
      .style('width', wrapperBox.width + 'px')
      .style('left', offsetWidth + 'px')

    topTable?.style('margin-left', - offsetWidth + 'px')

    leftHead?.style('height', wrapperBox.height + 'px')
      .style('width', offsetWidth + 'px')
      .style('top', offsetHeight + 'px')

    leftTable?.style('margin-top', - offsetHeight + 'px')

    topLeftHead?.style('width', leftHead?.style('width') || offsetWidth + 'px')
      .style('height', topHead?.style('height') || offsetHeight + 'px')

    wrapperNode.scrollTop = origScroll
    if _.showScrollIndicators
      scrollOffsetWidth = offsetWidth - 1
      scrollOffsetHeight = offsetHeight - 1

      topIndicator = container.shallowSelect('.hx-sticky-table-scroll-top')
        .style('top', scrollOffsetHeight + 'px')
        .style('left', scrollOffsetWidth + 'px')
        .style('width', wrapperBox.width + 'px')

      rightIndicator = container.shallowSelect('.hx-sticky-table-scroll-right')
        .style('top', scrollOffsetHeight + 'px')
        .style('height', wrapperBox.height + 'px')

      bottomIndicator = container.shallowSelect('.hx-sticky-table-scroll-bottom')
        .style('left', scrollOffsetWidth + 'px')
        .style('width', wrapperBox.width + 'px')

      leftIndicator = container.shallowSelect('.hx-sticky-table-scroll-left')
        .style('top', scrollOffsetHeight + 'px')
        .style('left', scrollOffsetWidth + 'px')
        .style('height', wrapperBox.height + 'px')

      updateScrollIndicators(wrapper, topIndicator, rightIndicator, bottomIndicator, leftIndicator)


    updateHeaderPositions(container, wrapper.node())

export {
  StickyTableHeaders
}
