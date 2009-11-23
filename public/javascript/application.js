$(document).ready( function() {
  var loading = $("<img src='/images/loading.gif' alt='loading' class='loading' />");

  $('.new_link').submit( function() {
    var phorm = $(this);
    var group_list = $("#group_list"); 
    var urls = phorm.children('input[name=url]').val();

    group_list.prepend(loading);
    $.post('/links', {url: urls}, function(data) {
      loading.remove();
      phorm.children('input[name=url]').val('');
      group_list.prepend(data);
    }, 'html');
    return false;
  });

  $('.link_out').live("click", function() {
    var link = $(this);
	var url = $(this).attr("href");
	var link_id = $(this).attr("id").replace(/^link_/, '');

	window.open(url);
    $.post('/links/'+ link_id +'/clicked', function(data) {
      link.siblings(".meta:first").children(".click_count:first").html(data);
    });
	return false;
  });
});
