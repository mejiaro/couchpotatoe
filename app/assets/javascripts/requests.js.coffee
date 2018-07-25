# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->

  if $('#direct-sign-trigger').length != 0
    directSign($('#direct-sign-trigger').data('contract-id'))


  if $('.backend').length != 0
    $('.help').tooltip()

    $('.request-popover').popover
      html: true
      trigger: 'click'
      content: ->
        $.ajax({url: "/requests/" + $(this).data('id'), dataType: 'html', async: false}).responseText;

    $(document).on 'click', (e) ->
      if $('.popover').is(':visible') && $(e.target).closest('.popover, .request-popover').length == 0
        $('.request-popover').popover('hide')

  $('.autosign-btn').click (e) ->
    e.preventDefault()
    directSign($(this).data('contract-id'))


directSign = (contractId) ->
  autoSignUrl = '/contracts/' + contractId  + '/autosign.js'
  $('#autosignModal .modal-content').load autoSignUrl, (r, s, xhr) ->
    if xhr.status == 500
      r = JSON.parse(r)
      window.location = r.url
    else
      $('#autosignModal').modal('show')
