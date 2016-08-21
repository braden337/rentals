$(document).ready(function() {

  var path = document.location.pathname.match(/\/?(\w+)?\/?.*/)[1];

  //
  // Highlight the current page
  //
  $('.navbar-nav li a').each(function() {
    var page = $(this).text().toLowerCase().trim();
    // console.log(text, text == path);
    if (page == path)
      $(this).parent().addClass('active');
  });

  if (path == 'login') {
    $('#name').focus()
  }
  else if (path == 'register') {
    $('#email').focus()
  }
  else {
    $('#amount').focus();
  }

});
