# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  if $('.modal').length != 0
    $('.modal').on 'shown.bs.modal', (e) ->
      $('.carousel').carousel()
      $('.carousel-control.left').click ->
        $('.carousel').carousel 'prev'
        return
      $('.carousel-control.right').click ->
        $('.carousel').carousel 'next'