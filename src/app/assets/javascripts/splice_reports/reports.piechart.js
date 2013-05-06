//= require "alchemy/jquery/plugins/flot-0.7/jquery.flot.js"
//= require "alchemy/jquery/plugins/flot-0.7/jquery.flot.pie"

var plot = function() {
	if (Splice.filtered_systems) {
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
}

$(document).ready(function() {
   	plot();
});

