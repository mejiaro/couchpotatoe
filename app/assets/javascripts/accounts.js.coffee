# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  if $("#autosignDisplay").length != 0

    canvas = document.getElementsByClassName('pad')
    context = canvas[0].getContext('2d')

    context.scale(0.4, 0.4)


    $('.sigPad').signaturePad({displayOnly: true, bgColour: 'transparent'}).regenerate($('#autosignDisplay').data('signature_data'))
