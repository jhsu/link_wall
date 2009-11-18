$(document).ready( function() {
  $('.new_link').submit( function() {
    var urls = $(this).children('input[name=url]').val();
    $.post('/links', {url: urls}, function(data) {
      $('#group_list').prepend(data);
    }, 'html');
    return false;
  });
});
