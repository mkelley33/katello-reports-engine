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




//= require "alchemy/jquery/plugins/jquery.timepickr"


KT.routes.splice_reports_filters_path = function(){return KT.routes.options.prefix + 'splice_reports/filters/'};
KT.panel.list.registerPage('splice_reports_filters', { create : 'new_splice_reports_filter' });

$(document).ready(function() {
    


    KT.panel.set_expand_cb(function(){

        //New Filter: Hide all fields by default
        $("#hour").hide();
        $("#daterange").hide();
        //you can only pick one satellite for now.. hide
        $("#satellite").hide();

        //New Filter: Hide the forms that are not selected
        $("#choose_hour").change(function(){
            $("#hour").show();
            $("#daterange").hide();
        });

        $("#choose_daterange").change(function() {
            $("#daterange").show();
            $("#hour").hide();            
        });
       

        //New Filter: If a user sets a value to a different field, reset any previous value in the
        // the other fields
        $("#splice_reports_filter_hours").change(function(){
            $("#splice_reports_filter_start_date").datepicker("setDate", null );
            $("#splice_reports_filter_end_date").datepicker("setDate", null );
        });
    
        $("#splice_reports_filter_start_date").change(function(){;
            $("#splice_reports_filter_hours").val(-1);
        });


        //New date pickers
        $(".datepicker").datepicker({
            changeMonth: true,
            changeYear: true
        });


        //Edit date pickers
        $('.edit_datepicker').each(function() {
            $(this).editable($(this).attr('data-url'), {
                type        :  'datepicker',
                width       :  300,
                method      :  'PUT',
                name        :  $(this).attr('name'),
                cancel      :  i18n.cancel,
                submit      :  i18n.save,
                indicator   :  i18n.saving,
                tooltip     :  i18n.clickToEdit,
                placeholder :  i18n.clickToEdit,
                submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
                onsuccess   :  function(result, status, xhr) {
//                    var plan_date = $("#plan_date").text();
//                    var current_plan = $("#current_plan").text();
//                    if (plan_date != current_plan) {
//                        $("#current_plan").text(plan_date);
//                    }
//                    var id = $('#plan_id');
//                    list.refresh(id.attr('value'), id.attr('data-ajax_url'));
                },
                onerror     :  function(settings, original, xhr) {
                  original.reset();
                  $("#notification").replaceWith(xhr.responseText);
                }
            });
        });
    });

});

