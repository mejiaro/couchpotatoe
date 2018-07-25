# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

setUpImageList = ->
  $('img.mini').popover
    html: true
    trigger: 'hover'
    content: ->
      '<img src="' + $(this).data('medium') + '" height="200px"/>'

  $('ul.images').sortable
    scroll: true
    placeholder: 'image-list-item'
    update: (event, ui) ->
      ui.item.find('.popover').remove()
      dataIndex = ui.item.index()
      dataId = ui.item.data('id')
      dataRiId = ui.item.data('rentable_item_id')

      $.ajax
        type: 'PUT'
        url: '/rentable_items/' + dataRiId + '/update_image'
        dataType: 'json'
        data: { image_id: dataId, presentation_order_position: dataIndex }

setupEdit = ->
  setUpImageList()

  $('.fileupload').fileupload
    dataType: 'html'
    done: (e, data) ->
      $(this).parent().find('.images').remove()
      $(this).parent().append(data.result)
      setUpImageList()
      $('.refresh-spinner').hide()

    start: ->
      $('.refresh-spinner').css({ 'display': 'block' })

  itattrs = $('#item-type-attributes').data('values')
  $('.itattrs').select2({tags: itattrs, width: '100%'})

jQuery ->
  container = $('.masonry_container')

  $(document).on 'click', (e) ->
    if $('#query-rentable-items-search').is(':visible') && $(e.target).closest('#query-rentable-items-search, #toggle-rentable-items-search').length == 0
      $('#toggle-rentable-items-search').click()


  if($('#newRentableItem').length != 0)
    $('#toggle-rentable-items-search').click ->
      $('#query-rentable-items-search').toggle().focus()
      $('#query-rentable-items-search').val('')

    $(document).keydown (e) ->
      if $('#query-rentable-items-search').is(':visible')
        ENTER = 13
        ESC = 27
        switch e.keyCode
          when ENTER
            window.location = '/rentable_items?query=' + $('#query-rentable-items-search').val()
          when ESC
            $('#toggle-rentable-items-search').click()

    $('.masonry_container').imagesLoaded ->

      container.masonry
        itemSelector: '.masonry_item'

      container.masonry 'on', 'layoutComplete', ->
        container.css('opacity', 1)

      container.masonry()

      if $('#highlighted').length != 0
        $("html, body").animate({ scrollTop: $('#highlighted').offset().top - 20 }, 1000)
        $('#highlighted').find('.edit-rentable-item').click()

    $('.add').click ->
      $('#newRentableItem').modal('show')


    $(document).on 'click', '.edit-rentable-item', (e) ->
      e.preventDefault()
      $this = $(this)
      rentableItemID = $this.data('rentable-item-id')

      href = '/rentable_items/' + rentableItemID + '/edit.js'

      $('#rentable-item-modal .modal-content').load href, ->
        $('#rentable-item-modal').on 'shown.bs.modal', ->
          window.history.pushState({}, "", '/rentable_items?item=' + rentableItemID)
          setupEdit()

        $('#rentable-item-modal').on 'hidden.bs.modal', ->
          $this.closest('.masonry_item').load '/rentable_items/' + $('.rentable-item').data('id') + '.js', ->
            $('.masonry_container').imagesLoaded ->
              container.masonry()

        $('#rentable-item-modal').modal('show')

    $(document).on 'ajax:complete', '.image-list-item > a.destroy', ->
      $(this).parent().remove()
      container.masonry()

    $(document).on 'ajax:complete', '.rentable-item form > a.destroy', ->
      $(this).parents('.rentable-item').remove()
      container.masonry()


    $(document).on 'ajax:success', '.edit_rentable_item', (_, html) ->
      $(this).find('.btn.submit').blur()

      tabpane = $(this).closest('.tab-pane')
      register = $(this).closest('.rentable-item').find('li.active a')

      tabpane.removeClass('success')
      register.removeClass('success')

      tabpane.offset()
      register.offset()

      tabpane.addClass('success')
      register.addClass('success')
  else
    $('a.show-gallery').click (e) ->
      e.preventDefault()
      $this = $(this)
      href = $this.attr('href')
      $('#rentable-item-modal .modal-content').load href, ->
        $('#rentable-item-modal').modal('show')
        window.history.pushState({}, "", '/rentable_items?item=' + $this.data('id'))

    $('#toggle-rentable-items-search').click ->
      $('#query-rentable-items-search').toggle().focus()
      $('#query-rentable-items-search').val('')

    applyFilter = (e, ui) ->
      e.preventDefault()
      window.location = ui.item.value

    filterTags = $("#query-rentable-items-search").data('filter-tags')
    $('#query-rentable-items-search').autocomplete
      source: filterTags
      position: { my: "center top", at: "center bottom", collision: "none" }
      select: applyFilter

    $(document).keydown (e) ->
      if $('#query-rentable-items-search').is(':visible')
        ENTER = 13
        ESC = 27
        switch e.keyCode
          when ENTER
            item = $('.ui-menu li:first-child').data('uiAutocompleteItem')
            applyFilter(e, { item: item })
          when ESC
            $('#toggle-rentable-items-search').click()

    $('.masonry_container').imagesLoaded ->
      $('.spinner').remove()

      container.masonry
        itemSelector: '.masonry_item'
      container.masonry 'on', 'layoutComplete', ->
        container.css('opacity', 1)
        if $('#highlighted').length != 0
          $('#highlighted').click()
        return true

      container.masonry()