var TrackerStats = {};

TrackerStats.add_datepicker = function(id){
    $('#' + id).datepicker({
        dateFormat: "yy/mm/dd"
    });
};

$(function() {
    TrackerStats.add_datepicker('start_date');
    TrackerStats.add_datepicker('end_date');
});
