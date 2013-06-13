/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/


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
          $("#description").show();
        }).click(function() {
          $("#description").hide();
        });
   	$("#description").click(function() {
          $("#description").hide();
	});
});

