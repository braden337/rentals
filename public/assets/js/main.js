$(document).ready(function() {

  var path = document.location.pathname.match(/\/?(\w+)?\/?.*/)[1] || '';

  $('.navbar-nav li a').each(function() {
    var page = $(this).text().toLowerCase().trim();
    // console.log(text, text == path);
    if (page == path)
      $(this).parent().addClass('active');
  });

  // switch (path) {
  //   case expression:
  //
  //     break;
  //   default:
  //
  // }
  // if (path == 'login') {
  //   $('#name').focus()
  // }
  // else if (path == 'register') {
  //   $('#email').focus()
  // }
  // else {
  //   $('#amount').focus();
  // }

  function checkIndex() {
    if ($('#amount').val() && $('#rental').val() !== 'None') {
      return true;
    }
    else {
      // alert('something went wrong');
      return false;
    }
  }

  $('form').submit(function(e) {
    switch (path) {
      case '':
        return checkIndex();
        break;
    }
  });



});
