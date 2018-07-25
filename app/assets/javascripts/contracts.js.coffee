# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).on "ajax:success", "a.deliver-bill", (e) ->
    alert "Der Mieter erhält nun eine Abrechnung per E-Mail."
    
  offsetNat = if $('.autosign-btn').length == 0 then 150 else 5
  $(document).on 'click', '#AutoSignContract img', (e) ->
    clickX = (e.offsetX || e.clientX - $(e.target).offset().left + window.pageXOffset)
    clickY = (e.offsetY || e.clientY - $(e.target).offset().top + window.pageYOffset)

    signature_position = [clickX / $(this).width(), clickY / $(this).height()]


    $.post '/contracts/' + $('#AutoSignContract').data('contract_id') + '/autosign.json', { document_type: 'signed_contract', signature_position: signature_position }, ->
      $('#AutoSignContract img').attr 'src', ($('#AutoSignContract img').attr('src') + '&time=' + (new Date).getTime())


      if $('#frontend').length != 0
        reloadRequests = ->
          location.reload()
        setTimeout(reloadRequests, 3000)

  $(document).on 'mousemove', '#AutoSignContract img', (e) ->
    hoverX = (e.offsetX || e.clientX - $(e.target).offset().left + window.pageXOffset)
    hoverY = (e.offsetY || e.clientY - $(e.target).offset().top + window.pageYOffset) + offsetNat

    $('#AutoSignContract #sigPlaceHolder').css 'left', hoverX
    $('#AutoSignContract #sigPlaceHolder').css 'top', hoverY


  $(document).on 'mouseleave', '#AutoSignContract img', (e) ->
    $('#AutoSignContract #sigPlaceHolder').hide()

  $(document).on 'mouseenter', '#AutoSignContract img', (e) ->
    $('#AutoSignContract #sigPlaceHolder').show()


  $(document).on 'click', '.set-deposit-state', ->
    $('.refresh-spinner').css 'display', 'inline-block'
    $.ajax $(this).data('update-contract-action'),
      type: 'PATCH',
      data: { contract: { deposit_paid: $(this).data('paid') } },
      complete: ->
        $('#contractModal .modal-content').load '/contracts/' + $('.tab-content').data('contract-id') + '/edit', ->
          $('a[href="#finances"]').tab('show')


  $('.show-contract-details').click (e) ->
    e.preventDefault()
    $('#contractModal .modal-content').load '/contracts/' + $(this).data('contract-id') + '/edit', ->
      $('#contractModal').modal('show')

  $('.edit_contract').submit ->
    $('.refresh-spinner').css 'display', 'inline-block'

  $('.edit_contract').bind 'ajax:complete', ->
    $('.refresh-spinner').hide()

  $(document).on 'click', '#regenerate-contract', ->
    $('.refresh-spinner').css 'display', 'inline-block'
    $.ajax
      url: '/contracts/' + $(this).data('contract-id') + '/regenerate'
      type: 'POST',
      dataType: 'JSON'
      success: (response) ->
        $('.refresh-spinner').css 'display', 'none'
        return
      error: (jqXHR, textStatus, errorThrown) ->
        console.log textStatus, errorThrown
        return