$(function() {
  $('#container_item_editor').on('click', '.container_item a.create', function(event){
    event.preventDefault();
    var item = $(event.currentTarget).parent();

    if($('#container_item_input').length) {
      $('#container_item_input').remove();
    }

    var input_html = '<li id="container_item_input"><input data-parent-id="' + item.data('id') + '" type="text"></input></li>';
    if(item.children('ul').length) {
      item.children('ul').prepend(input_html);
    } else {
      item.append('<ul class="container_items">' + input_html + '</ul>');
    }
  });

  $('#container_item_editor').on('click', '.container_item a.delete', function(event){
    event.preventDefault();
    var item = $(event.currentTarget).parent();

    $.ajax({
      type: "DELETE",
      url: '/container_items/' + item.data('id') + '.json',
      success: function() {
        item.remove();
      }
    });
  });

  $('#container_item_editor').on('keyup', '#container_item_input input', function(event){
    event.preventDefault();

    var input = $(event.currentTarget);

    if(input.data('running')!='yes') {
      input.data('running', 'yes');
      var name = input.val();
      var parentId = input.data('parent-id');

      if(event.keyCode == 13) {
        $.ajax({
          type: "POST",
          url: '/container_items.json',
          data: { container_item: { name: name, parent_id: parentId }},
          success: function(response) {
            input.parent().replaceWith('<li data-id="' + response.id + '" class="container_item"><a class="create" href="#">' + response.name + '</a> ( <a class="delete" href="#">x</a> )</li>');
          }
        });
      }
    }

    input.data('running', 'no');
  });
});