$(document).ready( function() {
  var loading = $("<img src='/images/loading.gif' alt='loading' class='loading' />");

  $('.new_link').submit( function() {
    var phorm = $(this);
    var group_list = $("#group_list"); 
    var urls = phorm.children('input[name=url]').val();
    group_list.prepend(loading);
    $.post('/links', {url: urls}, function(data) {
      group_list.children('img.loading').remove();
      phorm.children('input[name=url]').val('');
      group_list.prepend(data);
    }, 'html');
    return false;
  });
});
