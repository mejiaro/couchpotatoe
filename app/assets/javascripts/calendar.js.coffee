jQuery ->
  if $('#calendar').length != 0
    if $('.backend').length != 0
      eventCreator = (start, end, jsEvent, view) ->
        if start.hasTime() && end.hasTime()
          $('#eventCreator .from').text start.format('HH:mm')
          $('#eventCreator .till').text end.format('HH:mm')
          $('#eventCreator').modal()
          $('#eventCreator button').click (e) ->
            e.preventDefault()
            posting = $.post '/calendars/interview_availability.json',
              start: start.format()
              end: end.format()
            posting.done ->
              $('#calendar').fullCalendar('refetchEvents')
              $('#eventCreator button').off 'click'
              $('#eventCreator').modal('hide')



      $('#calendar').fullCalendar
        lang: 'de'
        events: '/calendars.json'
        selectable: true
        allDayDefault: false
        header:
          left:   'title'
          center: 'agendaDay month'
          right:  'today prev,next'
        dayClick: (date) ->
          $('#calendar').fullCalendar('changeView', 'agendaDay')
          $('#calendar').fullCalendar('gotoDate', date)
        select: eventCreator
    else
      rentable_item_id = if $('#calendar').data('rentable_item_id') then $('#calendar').data('rentable_item_id') else ''
      source = { url: '/calendars.json' + '?rentable_item_id=' + (rentable_item_id) }

      $('#calendar').fullCalendar
        lang: 'de'
        events: source
        allDayDefault: false
        header:
          left:   'title'
          center: 'agendaDay month'
          right:  'today prev,next'
        dayClick: (date) ->
          $('#calendar').fullCalendar('changeView', 'agendaDay')
          $('#calendar').fullCalendar('gotoDate', date)
        eventClick: (event) ->
          posting = $.post '/calendars/schedule_interview',
            rentable_item_id: rentable_item_id
            start: event.start.format()
            end: event.end.format()
          posting.done (r) ->
            unless r.failure
              $('#calendar').fullCalendar 'removeEventSource', source
              $('#calendar').fullCalendar 'addEventSource', '/calendars.json'
              $('#calendar').fullCalendar('refetchEvents')

