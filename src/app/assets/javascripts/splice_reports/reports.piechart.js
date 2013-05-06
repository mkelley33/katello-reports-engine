//= require "alchemy/jquery/plugins/flot-0.7/jquery.flot.js"
//= require "alchemy/jquery/plugins/flot-0.7/jquery.flot.pie"

var plot = function() {
	if (KT.subscription_data) {
	    $.plot($("#sub_graph"), KT.subscription_data, {
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

