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

  function checkRental() {
    var tenant = $('#tenant').val();
    var address = $('#address').val();
    var rent = $('#rent').val();
    var is_commercial = $('#commercial').prop('checked');
    var tax = $('#tax').val();
    var insurance = $('#rent').val();

    if (tenant && address && rent > 0) {
      if (is_commercial) {
        return (tax && insurance) ? true : false;
      }
      else {
        return true;
      }
    }
    
  }

  $('form').submit(function(e) {
    switch (path) {
      case '':
        return checkIndex();
        break;
      case 'rental':
        return checkRental();
        break;
    }
  });


  $('#commercial').on('change', function() {
    $('#commercial_info').toggleClass('hidden');
  });


});
