$(document).ready(function() {

  var path = document.location.pathname.match(/\/?(\w+)?\/?.*/)[1];

  //
  // Highlight the current page
  //
  $('.navbar-nav li a').each(function() {
    var text = $(this).text().toLowerCase().trim();
    // console.log(text, text == path);
    if (text == path)
      $(this).parent().addClass('active');
  });

  $('#amount').focus();

});
