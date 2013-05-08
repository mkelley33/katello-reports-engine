//= require "alchemy/jquery/plugins/jquery.timepickr"


KT.routes.splice_reports_filters_path = function(){return KT.routes.options.prefix + 'splice_reports/filters/'};
KT.panel.list.registerPage('splice_reports_filters', { create : 'new_splice_reports_filter' });

$(document).ready(function() {
    


    KT.panel.set_expand_cb(function(){

        $("#choose_hour").change(function(){
            $("#hour").show();
            $("#daterange").hide();
            $("#inactive").hide();
        });

        $("#splice_reports_filter_hours").change(function(){
            $("#splice_reports_filter_inactive").val("nill")
            $("#splice_reports_filter_start_date").datepicker("setDate", null );
            $("#splice_reports_filter_end_date").datepicker("setDate", null);
        });
    
        $("#choose_daterange").change(function() {
            $("#daterange").show();
            $("#hour").hide();
            $("#inactive").hide();            
        });

        $("#splice_reports_filter_start_date").change(function(){
            $("#splice_reports_filter_inactive option:selected").remove();
            $("#splice_reports_filter_hours option:selected").remove();
        });

        $("#choose_inactive").change(function() {
            $("#inactive").show();
            $("#hour").hide();
            $("#daterange").hide();            
        });

        $("#splice_reports_filter_inactive").change(function(){
            $("#splice_reports_filter_hours").val("nill");
            $("#splice_reports_filter_start_date").datepicker("setDate", null );
            $("#splice_reports_filter_end_date").datepicker("setDate", null);
        });


        $("#hour").hide();
        $("#daterange").hide();
        $("#inactive").hide();

        if (document.getElementById("start_date")){
            if (document.getElementById("start_date").innerHTML != null){
                $("#daterange".show);
            }
        }

        else if (document.getElementById("num_hours")){
            if (document.getElementById("num_hours").innerHTML != null){
                $("#hour").show();
            }
        }
        else if (document.getElementById("days_inactive")){
            if (document.getElementById("num_hours").innerHTML != null){
                $("#hour").show();
            }
        }



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

