$(document).ready(function() {

  $("body").on('click', 'li.panel_link', function() {
    console.log('click panel');
  });
  
  $("#filter_tip").click(function() {
    $("#description").show();
  });
  $("#description").click(function() {
    $("#description").hide();
  });
   
});
