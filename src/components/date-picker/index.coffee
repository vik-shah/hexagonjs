import { mergeDefined, randomId, supports } from 'utils/utils'
import { select, div, detached } from 'utils/selection'
import { EventEmitter } from 'utils/event-emitter'
import { preferences } from 'utils/preferences'
import { dateTimeLocalizer, IntlDateTimeLocalizer } from 'utils/date-localizer'
import logger from 'utils/logger'

import { NumberPicker } from 'components/number-picker'
import { Dropdown } from 'components/dropdown'

# Builds the array of days to display on the calendar in 'm' view
getCalendarMonth = (year, month, weekStart) ->
  start = (new Date(year, month)).getDay() - weekStart
  if start < 0 then start += 7
  end = new Date(year, month + 1, 0).getDate()
  results = []
  results.push if start > 0 then (undefined for _ in [0..start-1]).concat([1..7-start]) else [1..7]
  i = 1 - start
  while i < end
    i += 7
    e = Math.min(i + 6, end)
    if i <= e then results.push [i..e]

  if results[results.length - 1].length < 7
    results[results.length - 1].length = 7
  results

# Returns the array of months to display on the calendar in 'y' view
getCalendarYear = ->
  [
    [0,1,2]
    [3,4,5]
    [6,7,8]
    [9,10,11]
  ]

# Builds the array of years to display on the calendar in 'd' view
getCalendarDecade = (year) ->
  # Get start of current decade
  while year % 10 isnt 0
    year -= 1

  res = []
  row = []
  for i in [0..11]
    if i > 0 and i % 3 is 0
      res.push row
      row = []
    row.push year - 1 + i
  res.push row
  res

isSelectable = (datepicker, year, month, day) ->
  validRange = datepicker.validRange()
  if validRange.start?
    validStart = new Date(validRange.start.getTime())

  if validRange.end?
    validEnd = new Date(validRange.end.getTime())

  # If we don't pass in month/day here then we assume the month/day will be
  # halfway through the year/month and use that to validate against.
  if year? and not month? and not day?
    month = 6
    day = 15
    validStart?.setDate(0)
    validEnd?.setDate(28)
    validStart?.setMonth(0)
    validEnd?.setMonth(11)

  if month? and not day?
    day = 15
    validStart?.setDate(0)
    validEnd?.setDate(28)

  visible = datepicker.visibleMonth()

  year ?= visible.year
  month ?= visible.month

  testDate = new Date(year, month, day)
  startIsSelectable = if validStart? then testDate >= validStart else true
  endIsSelectable = if validEnd? then testDate <= validEnd else true
  startIsSelectable and endIsSelectable


isSelected = (selectedDate, year, month, day) ->
  [selectedYear, selectedMonth, selectedDay] = selectedDate.split('-').map(Number)

  selectedYear is year and
  (not month? or selectedMonth - 1 is month) and
  (not day? or selectedDay is day)


isBetweenDates = (range, year, month, day) ->
  testDate = new Date(year, month, day)
  testDate > range.start and testDate < range.end

isToday = (year, month, day) ->
  today = new Date()
  date = new Date(year, month, day)
  date.setHours(0, 0, 0, 0)
  today.setHours(0, 0, 0, 0)
  date.getTime() is today.getTime()


toggleInputValidity = (input, dateValidityCallback, valid, type) ->
  if input?
    if dateValidityCallback
      dateValidityCallback(valid, type)
    else
      input.classed('hx-date-error', !valid)

# Checks that the start and end dates fall within the valid range and that the
# end date is always after the start date.
validateDates = (datepicker) ->
  _ = datepicker._
  isRangePicker = datepicker.options.selectRange
  if datepicker.options.v2Features.dontModifyDateOnError
    validityFn = _.inputOnlyMode and datepicker.options.v2Features.dateValidityCallback
    toggleInputValidity(_.input, validityFn, true)

    _.inputStart?.classed('hx-date-error', false)
    _.inputEnd?.classed('hx-date-error', false)
    if _.validRange?
      if _.validRange.start?
        if _.startDate < _.validRange.start
          toggleInputValidity(_.input, validityFn, false, 'DATE_OUTSIDE_RANGE_START')
          _.inputStart?.classed('hx-date-error', true)

        if isRangePicker and _.endDate < _.validRange.start
          _.inputEnd?.classed('hx-date-error', true)

      if _.validRange.end?
        if _.startDate > _.validRange.end
          toggleInputValidity(_.input, validityFn, false, 'DATE_OUTSIDE_RANGE_END')
          _.inputStart?.classed('hx-date-error', true)

        if isRangePicker and _.endDate > _.validRange.end
          _.inputEnd?.classed('hx-date-error', true)
  else
    if _.validRange?
      if _.validRange.start?
        if _.startDate < _.validRange.start
          _.startDate = new Date(_.validRange.start.getTime())

        if isRangePicker and _.endDate < _.validRange.start
          _.endDate = new Date(_.validRange.start.getTime())

      if _.validRange.end?
        if _.startDate > _.validRange.end
          _.startDate = new Date(_.validRange.end.getTime())

        if isRangePicker and _.endDate > _.validRange.end
          _.endDate = new Date(_.validRange.end.getTime())

    if not isRangePicker
      _.endDate = _.startDate
    else
      if _.endDate < _.startDate
        tDate = _.endDate

        _.endDate = _.startDate
        _.startDate = tDate

  return


# Functions for setting up the calendar picker
buildCalendar = (datepicker, mode) ->
  _ = datepicker._

  _.calendarGrid.selectAll('.hx-grid-row').remove()
  _.calendarView = _.calendarGrid.view('.hx-grid-row', 'div')
    .update (d, e, i) -> calendarGridUpdate datepicker, d, e, i, mode

  mode ?= _.mode
  _.mode = mode

  localizer = datepicker.localizer

  visible = datepicker.visibleMonth()

  switch mode
    when 'd'
      data = getCalendarDecade(visible.year)
      cls = 'hx-calendar-decade'
      text = localizer.year(data[0][1]) + ' - ' + localizer.year(data[3][1])
    when 'y'
      data = getCalendarYear()
      cls = 'hx-calendar-year'
      text = localizer.year(visible.year)
    else
      data = getCalendarMonth(visible.year, visible.month - 1, localizer.weekStart())
      data.unshift 'days' # When the update gets to this it adds the days of the week as a row
      cls = 'hx-calendar-month'
      if datepicker.options.v2Features.displayLongMonthInCalendar
        text = "#{localizer.fullMonth(visible.month - 1)} #{localizer.year(visible.year)}"
      else
        text = localizer.month(visible.month - 1) + ' / ' + localizer.year(visible.year)

  _.calendarGrid.class('hx-calendar-grid ' + cls)
  _.calendarHeadBtn.text(text)
  _.calendarTodayButton?.text(localizer.todayText())
  _.calendarView.apply(data)

calendarGridUpdate = (datepicker, data, elem, index, mode) ->
  _ = datepicker._
  element = select(elem)

  if data is 'days'
    element
      .classed 'hx-grid-row-heading', true
      .view '.hx-grid'
      .update (d) -> @text(d).node()
      .apply(datepicker.localizer.weekDays())
  else
    element.view('.hx-grid')
      .enter (d) ->
        node = @append('div').class('hx-grid')
        if datepicker.options.selectRange
          node.append('div').class('hx-grid-range-bg')
        node.append('div').class('hx-grid-text')
        node.node()
      .update (d, e, i) -> calendarGridRowUpdate datepicker, d, e, i, index, mode
      .apply(data)

calendarGridRowUpdate = (datepicker, data, elem, index, rowIndex, mode) ->
  _ = datepicker._
  element = select(elem)
  if not data?
    element.classed('hx-grid-out-of-range', true)
      .classed('hx-grid-selected', false)
      .classed('hx-grid-selected-start', false)
      .classed('hx-grid-selected-end', false)
      .classed('hx-grid-selected-range', false)
      .classed('hx-grid-today', false)
  else
    year = null
    month = null
    day = null

    visible = datepicker.visibleMonth()

    selectable = true

    switch mode
      when 'd'
        year = data
        screenVal = datepicker.localizer.year(data)
        selectable = if rowIndex is 0 then index isnt 0 else if rowIndex is 3 then index isnt 2 else true
      when 'y'
        month = data
        year = visible.year
        screenVal = datepicker.localizer.month(data)
      else
        day = data
        month = visible.month - 1
        year = visible.year
        screenVal = datepicker.localizer.day(data)

    isValid = isSelectable(datepicker, year, month, day) and selectable

    if datepicker.options.selectRange
      range = datepicker.range()
      selectedS = isSelected(datepicker.localizer.date(range.start, true), year, month, day)
      selectedE = isSelected(datepicker.localizer.date(range.end, true), year, month, day)
      betweenDates = isBetweenDates(range, year, month, day)
      selected = selectedS or selectedE
    else
      selected = isSelected(datepicker.localizer.date(_.startDate, true), year, month, day)

    today = day and isToday(year, month, day)

    element.classed('hx-grid-out-of-range', not isValid)
      .classed('hx-grid-selected', selected)
      .classed('hx-grid-selected-start', selectedS)
      .classed('hx-grid-selected-end', selectedE)
      .classed('hx-grid-selected-range', betweenDates)
      .classed('hx-grid-today', today)

    element.select('.hx-grid-text').text(screenVal)

    if isValid
      element.on 'click', 'hx-date-picker', ->
        _.userEvent = true
        if mode isnt 'd' and mode isnt 'y'
          if day?
            currentDate = _.startDate

            currentDay = _.startDate.getDate()
            [,,localizedDay] = datepicker.localizer.date(_.startDate, true).split('-').map(Number)
            dayDiff = currentDay - localizedDay

            date = new Date(
              visible.year,
              visible.month - 1,
              day + dayDiff,
              currentDate.getHours(),
              currentDate.getMinutes(),
              currentDate.getSeconds(),
              currentDate.getMilliseconds()
            )
            if not datepicker.options.selectRange
              datepicker.date(date)
              if datepicker.options.closeOnSelect then datepicker.hide()
            else
              _.clickStart ?= true

              if _.clickStart
                _.clickStart = false
                datepicker.range({
                  start: date
                  end: date
                })
              else
                _.clickStart = true
                datepicker.range({
                  start: _.startDate
                  end: date
                })
                if datepicker.options.closeOnSelect then datepicker.hide()
        else
          if mode is 'd'
            nMode = 'y'
            datepicker.visibleMonth(6, data)
          else
            nMode = 'm'
            datepicker.visibleMonth(data + 1, visible.year)

        setupInput datepicker
        buildCalendar datepicker, nMode
    else
      element.on 'click', -> return


# Functions for setting up the datepicker picker
buildDatepicker = (datepicker) ->
  _ = datepicker._

  day = datepicker.day()
  month = datepicker.month()
  year = datepicker.year()
  localizer = datepicker.localizer
  _.dayPicker.suppressed 'change', true
  _.monthPicker.suppressed 'change', true
  _.yearPicker.suppressed 'change', true
  _.dayPicker.value(day, localizer.day(day, true))
  _.monthPicker.value(month, localizer.month(month - 1, true))
  _.yearPicker.value(year, localizer.year(year))
  _.dayPicker.suppressed 'change', false
  _.monthPicker.suppressed 'change', false
  _.yearPicker.suppressed 'change', false



# Shared Functions for both picker types
setupInput = (datepicker, initial) ->
  _ = datepicker._

  if datepicker.options.selectRange
    range = datepicker.range()
    _.inputStart.value(datepicker.localizer.date range.start, _.useInbuilt)
    _.inputEnd.value(datepicker.localizer.date range.end or range.start, _.useInbuilt)
  else
    if not (datepicker.options.v2Features.dontSetInitialInputValue and initial)
      _.input.value(datepicker.localizer.date(_.startDate, _.useInbuilt))


# Function for updating the input fields and emitting the change event.
updateDatepicker = (datepicker, suppress, initial) ->
  _ = datepicker._
  validateDates(datepicker)
  if not _.preventFeedback
    _.preventFeedback = true
    if datepicker.options.selectRange
      _.inputStart.classed('hx-date-error', false)
      _.inputEnd.classed('hx-date-error', false)
    else if _.inputOnlyMode
      datepicker.options.dateValidationChange?(true)
    else
      _.input.classed('hx-date-error', false)
    setupInput datepicker, initial
    if not suppress
      datepicker.emit 'change', {type: if _.userEvent then 'user' else 'api'}
    _.userEvent = false
    _.preventFeedback = false

    if datepicker.options.type == 'calendar'
      buildCalendar datepicker
    else
      buildDatepicker datepicker


class DatePicker extends EventEmitter
  constructor: (@selector, options) ->
    super()

    self = this

    @options = mergeDefined({
      type: 'calendar' # 'calendar' or 'datepicker'
      defaultView: 'm' # 'm' for month, 'y' for year, or 'd' for decade
      allowViewChange: true # Allow changing between month/year/decade views
      closeOnSelect: true
      selectRange: false
      validRange: undefined
      range: undefined
      showTodayButton: true
      allowInbuiltPicker: true # Option to allow preventing use of the inbuilt datepicker
      disabled: false
      date: undefined
      v2Features: {
        outputFullDate: false,
        dontModifyDateOnError: false,
        displayLongMonthInCalendar: false,
        dontSetInitialInputValue: false,
        updateVisibleMonthOnDateChange: false,
        dateValidityCallback: undefined # Called when validating the input when using dontModifyDateOnError
      },
    }, options)

    _ = @_ = {
      disabled: @options.disabled
      mode: @options.defaultView
      startDate: new Date(@options.date || Date.now())
      endDate: new Date(@options.date || Date.now())
    }

    @localizer = if preferences._.useIntl
      new IntlDateTimeLocalizer()
    else
      dateTimeLocalizer()

    @localizer.on 'localechange', 'hx.date-picker', => updateDatepicker this, true
    @localizer.on 'timezonechange', 'hx.date-picker', => updateDatepicker this, true

    @selection = select(@selector)
      .api('date-picker', this)
      .api(this)

    _.inputOnlyMode = @selection.node().tagName.toLowerCase() is 'input'

    if not @options.allowViewChange
      @options.defaultView = 'm'

    if _.inputOnlyMode
      if @options.selectRange
        logger.warn('DatePicker: options.selectRange is not supported when using an input')
        @options.selectRange = false
    else
      @selection.classed('hx-date-picker', true)

      inputContainer = @selection.append('div').class('hx-date-input-container')
      icon = inputContainer.append('i').class('hx-icon hx-icon-calendar')

    timeout = undefined

    if @options.selectRange
      # For range selection, we don't want the today button and have to use a calendar.
      @options.type = 'calendar'
      @options.showTodayButton = false
      _.preventFeedback = true
      @range(@options.range or {})
      _.preventFeedback = false

      inputUpdate = (which) ->
        self.hide()
        clearTimeout timeout
        timeout = setTimeout ->
          date1 = self.localizer.stringToDate(_.inputStart.value(), _.useInbuilt)
          date2 = self.localizer.stringToDate(_.inputEnd.value(), _.useInbuilt)
          if which and date2 < date1
            date1 = date2
            _.inputStart.value(_.inputEnd.value())
          else if not which and date1 > date2
            date2 = date1
            _.inputEnd.value(_.inputStart.value())
          startValid = date1.getTime()
          endValid = date2.getTime()
          if startValid and endValid
            self.range({start: date1, end: date2})
            self.visibleMonth(date1.getMonth() + 1, date1.getFullYear())

          _.inputStart.classed('hx-date-error', not startValid)
          _.inputEnd.classed('hx-date-error', not endValid)
        , 500

      _.inputStart = inputContainer.append('input').class('hx-date-input')
        .on 'input', 'hx.date-picker', -> inputUpdate(false)

      inputContainer.append('i').class('hx-date-to-icon hx-icon hx-icon-angle-double-right')

      _.inputEnd = inputContainer.append('input').class('hx-date-input')
        .on 'input', 'hx.date-picker', -> inputUpdate(true)
    else
      _.useInbuilt = if @options.allowInbuiltPicker
        not moment? and supports('date') and supports('touch')
      else false

      _.input = if _.inputOnlyMode
        @selection
      else
        inputContainer.append('input').class('hx-date-input')

      _.input.on (if _.useInbuilt then 'blur' else 'input'), 'hx.date-picker', ->
        self.hide()
        clearTimeout timeout
        timeout = setTimeout ->
          if self.options.v2Features.dontSetInitialInputValue and _.input.value() is ''
            if self.options.v2Features.dateValidityCallback
              self.options.v2Features.dateValidityCallback(true)
            else
              _.input.classed('hx-date-error', false)
            return

          date = self.localizer.stringToDate(_.input.value(), _.useInbuilt)
          if date.getTime()
            if date.getTime() isnt _.startDate.getTime()
              self.date(date)
              if not self.options.v2Features.updateVisibleMonthOnDateChange and self.options.type is 'calendar'
                self.visibleMonth(date.getMonth() + 1, date.getFullYear())
          else
            if self.options.v2Features.dateValidityCallback
              self.options.v2Features.dateValidityCallback(false, 'INVALID_DATE')
            else
              _.input.classed('hx-date-error', true)
        , 500

      if _.useInbuilt
        _.input.attr('type', 'date')
          .on 'focus', 'hx.date-picker', ->
            self.emit('show')

    if @options.type is 'calendar'
      @visibleMonth(undefined)

      changeVis = (multiplier = 1) ->
        visible = self.visibleMonth()
        switch _.mode
          when 'd'
            month = visible.month
            year = visible.year + (10 * multiplier)
          when 'y'
            month = visible.month
            year = visible.year + (1 * multiplier)
          else
            month = visible.month + (1 * multiplier)
            year = visible.year

        self.visibleMonth(month, year)
        buildCalendar self

      calendarElem = div('hx-date-picker-calendar')

      calendarHeader = calendarElem.append('div')
        .class('hx-calendar-header')

      calendarHeader.append('button')
        .class('hx-btn hx-btn-outline hx-calendar-back')
        .on 'click', 'hx.date-picker', -> changeVis(-1)
        .append('i').class('hx-icon hx-icon-chevron-left')

      if @options.allowViewChange
        calendarHeader.classed('hx-input-group', true)
        _.calendarHeadBtn = calendarHeader.append('button')
          .class('hx-btn hx-btn-invert')
          .on 'click', 'hx.date-picker', ->
            switch _.mode
              when 'd' then return
              when 'y' then buildCalendar self, 'd'
              else buildCalendar self, 'y'
      else
        calendarHeader.classed('hx-compact-group', true)
        _.calendarHeadBtn = calendarHeader.append('div')

      _.calendarHeadBtn.classed('hx-calendar-header-title', true)

      calendarHeader.append('button')
        .class('hx-btn hx-btn-outline hx-calendar-forward')
        .on 'click', 'hx.date-picker', -> changeVis()
        .append('i').class('hx-icon hx-icon-chevron-right')

      _.calendarGrid = calendarElem.append('div').class('hx-calendar-grid')

      if @options.showTodayButton
        _.calendarTodayButton = calendarElem.append('div')
          .class('hx-calendar-today-btn')
          .append('button')
          .class('hx-btn hx-btn-outline')
          .on 'click', 'hx.date-picker', ->
            date = new Date()
            self.date(date)
            buildCalendar self, 'm'
            if self.options.closeOnSelect
              self.hide()

      # XXX Breaking: Renderer
      # setupDropdown = () ->
      #   if _.disabled
      #     self.hide()
      #     return
      #   else
      #     _.clickStart = true
      #     selection = div()
      #     selection.append(calendarElem)
      #     buildCalendar self, self.options.defaultView
      #     return selection
      setupDropdown = (elem) ->
        if _.disabled
          self.hide()
          return

        _.clickStart = true
        selection = select(elem)
        selection.append(calendarElem)
        buildCalendar self, self.options.defaultView

    else
      # set up datepicker nodes for attaching to dropdown
      dayNode = div().node()
      monthNode = div().node()
      yearNode = div().node()

      _.dayPicker = new NumberPicker(dayNode, {buttonClass: 'hx-btn-outline'})
        .on 'change', 'hx.date-picker', (e) ->
          _.userEvent = true
          self.day e.value

      _.monthPicker = new NumberPicker(monthNode, {buttonClass: 'hx-btn-outline'})
        .on 'change', 'hx.date-picker', (e) ->
          _.userEvent = true
          self.month e.value

      _.yearPicker = new NumberPicker(yearNode, {buttonClass: 'hx-btn-outline'})
        .on 'change', 'hx.date-picker', (e) ->
          _.userEvent = true
          self.year e.value

      _.dayPicker.selectInput.attr('tabindex', 1)
      _.monthPicker.selectInput.attr('tabindex', 2)
      _.yearPicker.selectInput.attr('tabindex', 3)

      # XXX Breaking: Renderer
      # setupDropdown = () ->
      #   if _.disabled
      #     self.dropdown.hide()
      #     return
      #   else
      #     selection = div()

      #     # add nodes in the correct order
      #     for i in self.localizer.dateOrder()
      #       switch i
      #         when 'DD' then selection.append(dayNode)
      #         when 'MM' then selection.append(monthNode)
      #         when 'YYYY' then selection.append(yearNode)

      #     buildDatepicker(self)

      #     return selection
      setupDropdown = (elem) ->
        if _.disabled
          self.dropdown.hide()
          return

        selection = select(elem)
        # add nodes in the correct order
        for i in self.localizer.dateOrder()
          switch i
            when 'DD' then selection.append dayNode
            when 'MM' then selection.append monthNode
            when 'YYYY' then selection.append yearNode
        buildDatepicker self

    if not _.useInbuilt
      @dropdown = new Dropdown(@selector, setupDropdown, {
        matchWidth: false
      })

      # showstart etc. don't make sense here as we don't care about the animations
      @dropdown.on 'hidestart', => @emit 'hide'
      @dropdown.on 'showstart', => @emit 'show'

    setupInput(this, true)
    if _.disable then @disabled(_.disabled)
    if @options.validRange then @validRange(@options.validRange, true)


  disabled: (disable) ->
    _ = @_
    if disable?
      if @dropdown? and @dropdown.isOpen() then @dropdown.hide()
      val = if disable then '' else undefined
      _.disabled = disable
      if @options.selectRange
        _.inputStart.attr('disabled', val)
        _.inputEnd.attr('disabled', val)
      else
        _.input.attr('disabled', val)
      this
    else
      !!_.disabled

  show: ->
    if not @_.useInbuilt
      @dropdown.show()
    else
      @_.input.node().focus()
    return this

  hide: ->
    if not @_.useInbuilt
      @dropdown.hide()
    else
      @emit 'hide'
    return this

  getScreenDate: (endDate) ->
    @localizer.date if not endDate then @_.startDate else @_.endDate

  visibleMonth: (month, year) ->
    _ = @_
    if @options.type is 'calendar'
      if arguments.length > 0
        year ?= _.visibleYear or @year()
        month ?= _.visibleMonth or @month()

        if month < 1
          month += 12
          year -= 1

        if month > 12
          month = month % 12
          year += 1

        _.visibleMonth = month - 1
        _.visibleYear = year
        this
      else
        {
          month: _.visibleMonth + 1
          year: _.visibleYear
        }
    else
      logger.warn('Setting the visible month only applies to date pickers of type \'calendar\'')
      this

  date: (date) ->
    _ = @_
    if date?
      date = new Date date.getTime()
      if @options.v2Features.updateVisibleMonthOnDateChange and @options.type is 'calendar'
        @visibleMonth(date.getMonth() + 1, date.getFullYear())
      _.startDate = date
      updateDatepicker(this)
      this
    else
      returnDate = new Date _.startDate.getTime()
      if not @options.outputFullDate
        returnDate.setHours(0, 0, 0, 0)
      return returnDate

  day: (day) ->
    _ = @_
    if day?
      _.startDate.setDate(day)
      updateDatepicker(this)
      this
    else
      _.startDate.getDate()

  month: (month) ->
    _ = @_
    if month?
      _.startDate.setMonth(month - 1) # JS month is 0 based
      updateDatepicker(this)
      this
    else
      _.startDate.getMonth() + 1

  year: (year) ->
    _ = @_
    if year?
      _.startDate.setFullYear(year)
      updateDatepicker(this)
      this
    else
      _.startDate.getFullYear()

  range: (range) ->
    _ = @_
    if @options.selectRange
      if arguments.length > 0
        if range.start?
          _.startDate = range.start

        if range.end?
          _.endDate = range.end

        updateDatepicker(this)
        this
      else
        returnStartDate = new Date _.startDate.getTime()
        returnEndDate = new Date _.endDate.getTime()
        if not @options.outputFullDate
          returnStartDate.setHours(0, 0, 0, 0)
          returnEndDate.setHours(0, 0, 0, 0)

        {
          start: returnStartDate
          end: returnEndDate
        }
    else
      logger.warn('datePicker.range can only be used for datepickers with \'selectRange\' of true')
      return this

  validRange: (validRange, initial) ->
    _ = @_
    _.validRange ?= {
      start: undefined
      end: undefined
    }
    if arguments.length > 0
      if 'start' of validRange
        _.validRange.start = validRange.start

      if 'end' of validRange
        _.validRange.end = validRange.end


      updateDatepicker(this, false, initial)
      this
    else
      _.validRange

  locale: (locale) ->
    if arguments.length > 0
      @localizer.locale(locale)
      this
    else
      @localizer.locale()

datePicker = (options) ->
  selection = if options?.v2Features?.useInput
    detached('input')
  else
    div()
  new DatePicker(selection, options)
  selection

export {
  datePicker,
  DatePicker
}
