configureTooltips = (chart) ->
  tip = d3.tip().attr('class', 'd3-tip').html (details) ->
    tooltip = '<p>' + "Zeitraum: " + details.range + '</p>'
    console.log(details)
    tooltip += '<p>' + 'Kaution: ' + (if details.deposit then 'bezahlt' else 'nicht bezahlt') + '</p>'
    return tooltip

  chart.mouseover (d, i, datum) ->
    $(this).css 'opacity', '0.9'
    $.get '/contracts/' + d['contract_id'] + '.json', (contract) =>
      tip.show(contract.details, this)

  chart.mouseout (d, i, datum) ->
    $(this).css 'opacity', '1'
    tip.hide()

  return tip;

addMonths = (date, months) ->
  return date + (parseInt(months) * 1296000000)

renderTimeline = (timeline, bookings, focusContract) ->
  scrollToBooking = undefined

  $.each bookings, (i, rentableItem) ->
    rentableItem.times.forEach (range) ->
      if (focusContract && (range.contract_id == focusContract.id)) || ((focusContract == undefined) && range.request)
        timeline.beginning(range.starting_time)
        timeline.ending(addMonths(range.starting_time, 15))

        range.focused = true unless range.request

        scrollToBooking = true
      else
        range.focused = false

  svg = d3.select('svg')

  svg.selectAll("g").remove()
  svg.selectAll("text").remove()
  svg.selectAll("line").remove()
  $('.d3-tip').remove()

  tip = configureTooltips(timeline)
  svg.datum(bookings).call(timeline)
  svg.call(tip)

  $('#BookingsContainer').css('opacity', 1)

  $('.spinner').hide()

  if scrollToBooking
    scrollTmout = undefined
    scrollFun = ->
      if $('#focused-booking, .requested_booking').length != 0
        clearTimeout(scrollTmout)
        if $('#focused-booking').length != 0
          focusedContract = $('#focused-booking')
        else
          focusedContract = $('.requested_booking')

        offset = focusedContract.attr('cy')

        $('#BookingsTimeline').scrollTop offset - 100
      else
        scrollTmout = setTimeout(scrollFun, 200)
    scrollFun()

jQuery ->
  if $('#BookingsContainer').length != 0
    chart = d3.timeline()

    containerWidth = $('#BookingsTimeline').width()
    chart.width(containerWidth)

    svg = d3.select("#BookingsTimeline").append("svg")

    defs = svg.append("defs");
    filter = defs.append("filter")
    .attr("id", "dropshadow")
    filter.append("feGaussianBlur")
    .attr("in", "SourceAlpha")
    .attr("stdDeviation", 3)
    .attr("result", "blur")
    filter.append("feOffset")
    .attr("in", "blur")
    .attr("dx", 2)
    .attr("dy", 2)
    .attr("result", "offsetBlur")
    feMerge = filter.append("feMerge")
    feMerge.append("feMergeNode")
    .attr("in", "offsetBlur")
    feMerge.append("feMergeNode")
    .attr("in", "SourceGraphic")

    svg.attr("width", containerWidth)

    startDate = $('#BookingsTimeline').data('start-date')
    chart.beginning(startDate)
    chart.ending(addMonths(startDate, 15))

    chart.itemHeight(20)

    chart.stack()

    chart.colors ->
      $('.tertiary_color').css('background-color')

    chart.mouseover (d, i, datum) ->

      $(this).css 'opacity', '0.7'
      $(this).css 'cursor', 'pointer'

    chart.mouseout (d, i, datum) ->
      $(this).css 'opacity', '1'

    tickInterval = if $(window).width() < 500 then 2 else 1
    console.log(tickInterval)
    chart.tickFormat
      format: d3.time.format("%d.%m.%y")
      tickTime: d3.time.month
      tickInterval: tickInterval
      tickSize: 1

    bookings = []

    updateBookings = (filter, callback) ->
      $.get '/rentable_items/bookings.json' + $(location).attr('search'), filter, callback

    updateBookings (data) ->
      bookings = data

      if data.length == 0
        $('#BookingsTimeline h2').show()
        $('#BookingsContainer').css('opacity', 1)
        $('.spinner').hide()
      else
        if focusContract = parseInt($('#BookingsTimeline').data('focus-contract'))
          renderTimeline(chart, bookings, { id:focusContract })
          showEditModal(focusContract)
        else
          renderTimeline(chart, bookings)

    chart.click (d, i, datum) ->
      showEditModal(d.contract_id)

    showEditModal = (contractId) ->
      $('#contractModal .modal-content').load '/contracts/' + contractId + '/edit', ->
#        window.history.pushState({}, "", '/rentable_items/bookings?contract_id=' + contractId)


        $('#contractModal').modal('show')

        $('.edit_contract').submit ->
          $('.refresh-spinner').css 'display', 'inline-block'

        $('.edit_contract').bind 'ajax:complete', ->
          $('.refresh-spinner').hide()

          updateBookings { container_item_id: $('.timeline-filter li.active a').data('container-item-id') }, (data) ->
            bookings = data
            renderTimeline(chart, bookings)


    $('.timeline-filter a').click (event) ->
      event.preventDefault()

      filter = { container_item_id: filter = $(this).data('container-item-id') }
      updateBookings filter, (data) ->
        bookings = data
        renderTimeline(chart, bookings)

    $('.date-change a').click (e) ->
      e.preventDefault()

      $(this).parent().parent().parent().data('selected', $(this).data('value'))

      startDate = new Date($('#bookings-year').data('selected'), $('#bookings-month').data('selected'), 1).getTime()
      startDate = addMonths(startDate, -3)
      chart.beginning startDate
      chart.ending(addMonths(startDate, 15))
      renderTimeline(chart, bookings, false)

    $('#toggle-bookings-search').click ->
      $('#query-bookings-search').toggle().focus().keydown()

    $(document).on 'click', (e) ->
      if $('#query-bookings-search').is(':visible') && $(e.target).closest('#query-bookings-search, #toggle-bookings-search').length == 0
        $('#toggle-bookings-search').click()

    moveSearchResult = (e, ui) ->
      e.preventDefault()


      renderTimeline(chart, bookings, ui.item.value)

      $('#query-bookings-search, .ui-menu').hide()


    $('#query-bookings-search').autocomplete
      source: '/searches/user_contracts'
      position: { my: "center top", at: "center bottom", collision: "none" }
      messages:
        noResults: ''
        results: ->
      select: moveSearchResult

    $(document).keydown (e) ->
      if $('#query-bookings-search').is(':visible')
        ENTER = 13
        ESC = 27
        switch e.keyCode
          when ENTER
            item = $('.ui-menu li:first-child').data('uiAutocompleteItem')
            moveSearchResult(e, { item: item })

          when ESC
            $('#query-bookings-search').hide()
