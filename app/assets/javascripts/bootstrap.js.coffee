jQuery ->
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()
  $(document).on 'mouseup', '.btn', ->
    $(this).blur()