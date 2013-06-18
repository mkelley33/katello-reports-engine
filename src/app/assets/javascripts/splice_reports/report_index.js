$(document).ready(function() {
  
   	$("#filter_tip").mouseover(function() {
   		  console.log("HOVER")
          $("#description").show();
        }).click(function() {
          $("#description").hide();
        });
   	$("#description").click(function() {
          $("#description").hide();
	});
});