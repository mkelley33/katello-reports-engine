//$(document).ready(function() {
  
//wait for page to finish loading
$(window).bind("load", function() {
    $("body").on('click', 'li.panel_link', function( e ) {
      console.log('click panel');
      //unable to stop details panel from refreshing twice
      //e.preventDefault();
      //e.stopPropagation();
      //e.stopImmediatePropagation();
      //$(this.firstChild).css("text-decoration", "underline");
      $(this.firstChild).addClass("selected");
    });
  
  $("#filter_tip").click(function() {
    $("#description").show();
  });
  $("#description").click(function() {
    $("#description").hide();
  });
   
});
