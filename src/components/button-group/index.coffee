import { select, div } from 'utils/selection'
import { mergeDefined } from 'utils/utils'
import { EventEmitter } from 'utils/event-emitter'

class ButtonGroup extends EventEmitter
  constructor: (selector, options) ->
    super()
    self = this

    @options = mergeDefined({
      buttonClass: 'hx-complement'
      activeClass: 'hx-action'
      fullWidth: false
      # XXX Breaking: Renderer
      # renderer: (data, current) ->
      #   return div().text(if data.value? then data.value else data)
      renderer: (node, data, current) ->
        select(node).text(if data.value? then data.value else data)
        return
      items: []
      disabled: false
    }, options)

    @current = undefined

    group = select(selector)
      .api('button-group', this)
      .api(this)
      .classed('hx-button-group', true)
      .append('div')
        .class('hx-input-group')
        .classed('hx-input-group-full-width', @options.fullWidth)

    @view = group.view('button')
      .enter ->
        @append('button')
          .class('hx-btn')
          .classed('hx-section hx-no-margin', self.options.fullWidth)
          .classed(self.options.buttonClass, true)
          .node()
      .update (item, node) ->
        buttonClass = if item.activeClass? and item is self.current then item.activeClass
        else if item is self.current then self.options.activeClass
        else self.options.buttonClass

        @class('hx-btn')
          .classed('hx-section hx-no-margin', self.options.fullWidth)
          .classed(buttonClass, true)
          .attr('disabled', if self.options.disabled then true else undefined)
          # XXX Breaking: Renderer
          # .set(self.options.renderer(item, item is self.current))
          .on 'click', 'hx.button-group', ->
            self.value(item, true)

        self.options.renderer(node, item, item is self.current)
        return



    if @options.items? and @options.items.length > 0
      @items @options.items

  renderer: (f) ->
    if f?
      @options.renderer = f
      this
    else
      @options.renderer

  items: (items) ->
    if items?
      @options.items = items
      @view.apply(@options.items)
      this
    else
      @options.items

  value: (value) ->
    if arguments.length > 0
      for item in @options.items
        if item is value or item.value is value
          @current = item
          @view.apply(@options.items)
          @emit('change', {value: item, cause: if arguments[1] then 'user' else 'api'})
          break
      this
    else
      @current

  disabled: (disabled) ->
    if arguments.length > 0
      @options.disabled = disabled
      @items(@items())
      return this
    else
      @options.disabled

buttonGroup = (options) ->
  selection = div()
  new ButtonGroup(selection.node(), options)
  selection

export {
  buttonGroup,
  ButtonGroup
}
