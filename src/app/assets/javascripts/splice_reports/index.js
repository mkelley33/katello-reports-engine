//= require "alchemy/jquery/plugins/jquery.timepickr"


KT.routes.splice_reports_filters_path = function(){return KT.routes.options.prefix + 'splice_reports/filters/'};
KT.panel.list.registerPage('splice_reports_filters', { create : 'new_splice_reports_filter' });

$(document).ready(function() {
    


    KT.panel.set_expand_cb(function(){
        $("#choose_hour").change(function(){
            console.log('choose_hour');
            $("#hour").show();
            $("#daterange").hide();
            $("#inactive").hide();
        });
    
        $("#choose_daterange").change(function() {
            console.log('choose_daterange');
            $("#daterange").show();
            $("#hour").hide();
            $("#inactive").hide();            
        });

        $("#choose_inactive").change(function() {
            console.log('choose_inactive');
            $("#inactive").show();
            $("#hour").hide();
            $("#daterange").hide();            
        });

        $("#hour").hide();
        $("#daterange").hide();
        $("#inactive").hide();

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
                onerror     :  function(settings, original, xhr) {
                  original.reset();
                  $("#notification").replaceWith(xhr.responseText);
                }
            });
        });
    });

});

