jQuery ->
  if $('.subjects').length != 0
    $('.chosen').select2()

    $('.msg-wrap').animate({ scrollTop: $('.msg-wrap').prop('scrollHeight') }, 1000)

    $('.conversation a').click ->
      $('.conversation').removeClass('active')
      $(this).parent().addClass('active')
      $('.msg-wrap').load '/subjects/' + $(this).data('id')

    replace = (response) ->
      console.log(response)
      $('.msg-wrap').html(response)

      $('.msg-wrap').animate({ scrollTop: $('.msg-wrap').prop('scrollHeight') }, 1000)
      $('textarea').val('')

    $('a.send-message').click ->
      $.post 'https://' + document.domain + '/subjects/' + $('#currentSubject').data('id') + '/send_message', text: $('textarea').val(), replace

    $('a.destroy').on 'ajax:complete', ->
      $(this).parent().hide('fast')
