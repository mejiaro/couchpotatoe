jQuery ->
  if $('#financeDashboard').length != 0

    $('#contractModal').on 'show.bs.modal', (e) ->
      $('a[href="#finances"]').tab('show')

    $('#toggle-search-receivables').click (e) ->
      e.preventDefault()

      $('#input-search-receivables').toggle().focus()
      $('#input-search-receivables').val('')

      allItems = $.makeArray($('ol li'))

      $.each allItems, (i, li) ->
        $(li).show()

    $(document).on 'click', (e) ->
      if $('#input-search-receivables').is(':visible') && $(e.target).closest('#input-search-receivables, #toggle-search-receivables').length == 0
        $('#toggle-search-receivables').click()

    searchTimeout = undefined

    $('#input-search-receivables').keydown (e) ->
      clearTimeout(searchTimeout)

      allItems = $.makeArray($('ol li'))

      if e.keyCode == 27
        $('#toggle-search-receivables').click()

      else
        filterByQuery = =>
          queryRegex = new RegExp(".*" + this.value + ".*", 'i')

          $.each allItems, (i, li) ->
            $li = $(li)
            if($li.find('strong > a').text().match(queryRegex))
              $li.show()
            else
              $li.hide()

        searchTimeout = setTimeout filterByQuery, 300

    monthNames = [
      "Januar"
      "Februar"
      "März"
      "April"
      "Mai"
      "Juni"
      "Juli"
      "August"
      "September"
      "Oktober"
      "November"
      "Dezember"
    ]

    newReceivables = $('#new-receivables').data('values')
    paidReceivables = $('#paid-receivables').data('values')

    chartData = [newReceivables, paidReceivables]

    chart = c3.generate
      tooltip:
        format:
          title: (d) -> monthNames[d]
          value: (value, ratio, id)  -> value + ' Euro'
          name: (g) -> { 'paid': 'Erfolgreich', 'new': 'Offen' }[g]

      axis:
        y:
          show: false
        x:
          type: 'category'
          categories: monthNames

      legend:
        show: false
      bar:
        width:
          ratio: 0.8
      data:
        color: ->
          undefined
        columns: chartData
        type: "bar"
        groups: [ [ "paid", "new" ]]
        onclick: (s) -> location.href = '/billing_cycles?month=' + (s.x + 1) + '&year=' + $('#year').data('year')


    $('.c3-bar-' + (parseInt($('#financeDashboard').data('selected-month')) - 1)).css 'fill-opacity', 1

    $("ol.receivables").sortable
      group: 'receivables'
      isValidTarget: (receivable, container) ->
        $receivable_parent = $(receivable).parent('ol')
        $container = $(container.target)
        if $receivable_parent.data('type') == 'direct-debit' && $container.data('type') == 'credit-transfer'
          false
        else if $receivable_parent.data('type') == 'credit-transfer' && $container.data('type') == 'direct-debit'
          false
        else
          true

      onDrop: (receivable, receivableState, renderDrop) ->
        newState = undefined

        switch receivableState.el.data('state')
          when 'new'
            newState = { paid: false }
          when 'paid'
            newState = { paid: true }

        $.ajax($(receivable).data('on-drop-action'), type: 'PATCH', data: receivable: newState )
        renderDrop(receivable, receivableState)

#        chart.load
#          columns: [['exported', 200]]
