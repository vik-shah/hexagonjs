import { select, div } from 'selection/main'
import { merge, randomId } from 'utils/main'
import { DatePicker } from 'date-picker/main'
import { TimePicker } from 'time-picker/main'
import { EventEmitter } from 'event-emitter/main'
import { preferences } from 'preferences/main'

export class DateTimePicker extends EventEmitter
  constructor: (@selector, options) ->
    super()

    @options = merge({
      datePickerOptions: {}
      timePickerOptions: {}
    }, options)

    # You can't select a range for a date-time picker.
    delete @options.datePickerOptions.selectRange

    @suppressCallback = false

    @selection = select(@selector)
      .classed('hx-date-time-picker', true)
      .api('date-time-picker', this)
      .api(this)

    dtNode = @selection.append('div')
    tpNode = @selection.append('div')

    # To prevent the two pickers being initialised with separate disabled properties.
    @options.timePickerOptions.disabled = @options.datePickerOptions.disabled

    @datePicker = new DatePicker(dtNode, @options.datePickerOptions)
    @timePicker = new TimePicker(tpNode, @options.timePickerOptions)

    @_ = {
      uniqueId: randomId()
    }

    # XXX [2.0.0]: memory leak
    preferences.on 'timezonechange', 'hx.date-time-picker-' + @_.uniqueId, -> updateDatePicker()

    @datePicker.pipe(this, 'date', ['show', 'hide'])
    @timePicker.pipe(this, 'time', ['show', 'hide'])

    updateTimePicker = (data) =>
      @timePicker.suppressed('change', true)
      @timePicker.date(@datePicker.date(), true)
      @timePicker.suppressed('change', false)

      if data?
        # Called here as otherwise calling @date() would return the previously set date
        @emit 'date.change', data
        @emit 'change', @date()

    updateDatePicker = (data) =>
      @datePicker.suppressed('change', true)
      @datePicker.date(preferences.applyTimezoneOffset(@date()))
      @datePicker.suppressed('change', false)

      if data?
        # Called here as otherwise calling @date() would return the previously set date
        @emit 'time.change', data
        @emit 'change', @date()

    @datePicker.on 'change', 'hx.date-time-picker', updateTimePicker
    @timePicker.on 'change', 'hx.date-time-picker', updateDatePicker

  date: (val, retainTime) ->
    if arguments.length > 0
      @timePicker.date val, retainTime
      this
    else @timePicker.date()

  year: (val) ->
    if arguments.length > 0
      @datePicker.year val
      this
    else @datePicker.year()

  month: (val) ->
    if arguments.length > 0
      @datePicker.month val
      this
    else @datePicker.month()

  day: (val) ->
    if arguments.length > 0
      @datePicker.day val
      this
    else @datePicker.day()

  hour: (val) ->
    if arguments.length > 0
      @timePicker.hour val
      this
    else @timePicker.hour()

  minute: (val) ->
    if arguments.length > 0
      @timePicker.minute val
      this
    else @timePicker.minute()

  second: (val) ->
    if arguments.length > 0
      @timePicker.second val
      this
    else @timePicker.second()

  getScreenDate: -> @datePicker.getScreenDate()
  getScreenTime: -> @timePicker.getScreenTime()

  # XXX [2.0.0]: remove?
  # See note in 2.0.0.md about retaining this method
  locale: (locale) ->
    # utils.deprecatedWarning 'hx.DateTimePicker::locale is deprecated. Please use hx.preferences.locale.'
    if arguments.length > 0
      preferences.locale locale
      this
    else
      preferences.locale()


  disabled: (disable) ->
    dpDisabled = @datePicker.disabled(disable)
    @timePicker.disabled(disable)
    if disable?
      this
    else
      dpDisabled


export dateTimePicker = (options) ->
  selection = div()
  new DateTimePicker(selection, options)
  selection
