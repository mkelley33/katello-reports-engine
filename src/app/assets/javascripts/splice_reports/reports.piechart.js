//= require "alchemy/jquery/plugins/flot-0.7/jquery.flot.js"
//= require "alchemy/jquery/plugins/flot-0.7/jquery.flot.pie"

var plot = function() {
        var show_graph = false;
        for(x = 0; x < Splice.filtered_systems.length; ++x){
            if(Splice.filtered_systems[x].data > 0){
	       show_graph = true; 
            }
        }
        
	if (show_graph) {
	    $.plot($("#sub_graph"), Splice.filtered_systems, {
	        series: {
	            pie:{
	                show: true,
	                radius: .8,
	                stroke: {
	                    width: 0
	                },

	                label: {
	                    show: false
	                }
	            }
	        },
	        legend: {
	            show: false
	        }
	    });
	}
     else {
         $("#overlay").hide()
     }
}

$(document).ready(function() {
   	plot();

   	$("#filter_tip").mouseover(function() {
          console.log("hover")
          $("#description").show();
        }).click(function() {
          $("#description").hide();
        });
   	$("#description").click(function() {
          console.log("hide")
          $("#description").hide();
	});
});

