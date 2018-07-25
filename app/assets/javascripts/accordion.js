$(document).ready(function(){

  $('ul.accordion li a').click(function(){

    $this = $(this);

    $this.siblings('p')
      .slideToggle('slow')
      .parents('ul')
      .find('p:visible')
      .not($this.siblings('p'))
      .slideToggle();

  }).siblings('p').hide();

});
