require('/assets/application.js');

describe("TrackerStats", function() {
    function selector(id){
        return '#' + id;
    }

    describe("#add_datepicker", function() {
        var ID = "my_datepicker";
        var DATEPICKER_CLASS = "hasDatepicker";
        var input;

        beforeEach(function(){
            $("#test").html("<input id='" + ID + "' type='text'/>");
            input = $(selector(ID));
        });


        it("adds a datepicker to the element with the given selector", function() {
            expect(input.hasClass(DATEPICKER_CLASS)).toBeFalsy();
            TrackerStats.add_datepicker(selector(ID));
            expect(input.hasClass(DATEPICKER_CLASS)).toBeTruthy();
        });

        it("adds a datepicker with the correct date format", function() {
            TrackerStats.add_datepicker(selector(ID));
            expect(input.datepicker("option", "dateFormat")).toBe("yy/mm/dd");
        });

    });

    describe("#setup_iterations_slider", function(){
        var SLIDER_ID = 'my_slider';
        var START_DATE_ID = 'start_date';
        var END_DATE_ID = 'end_date';
        var SLIDER_CLASS = 'ui-slider';
        var slider;
        var iterations;

        beforeEach(function(){
            $("#test").html("<div id='" + SLIDER_ID + "'/>");
            slider = $(selector(SLIDER_ID));

            iterations = ["", "2012/01/01", "2012/02/01", "2012/03/01"];
            TrackerStats.set_property("iterations", iterations);

            $("#test").append("<input id='" + START_DATE_ID + "' type='text'/>");
            $("#test").append("<input id='" + END_DATE_ID + "' type='text'/>");
        });

        it("adds a range slider to the page", function(){
            expect(slider.hasClass(SLIDER_CLASS)).toBeFalsy();
            TrackerStats.setup_iterations_slider(selector(SLIDER_ID));
            expect(slider.hasClass(SLIDER_CLASS)).toBeTruthy();
            expect(slider.slider("option", "range")).toBeTruthy();
        });

        it("should use the pre-configured iterations", function(){
            TrackerStats.setup_iterations_slider(selector(SLIDER_ID));
            expect(slider.slider("option", "min")).toEqual(0);
            expect(slider.slider("option", "max")).toEqual(3);
        });

        it("changing slider should update date selectors", function(){
            TrackerStats.setup_iterations_slider(selector(SLIDER_ID),
                selector(START_DATE_ID), selector(END_DATE_ID));

            // Case #1
            slider.slider("values", 0, 1);
            slider.slider("values", 1, 2);

            expect($(selector(START_DATE_ID)).val()).toEqual(iterations[1]);
            expect($(selector(END_DATE_ID)).val()).toEqual(iterations[3]);

            // Case #2
            slider.slider("values", 0, 0);
            slider.slider("values", 1, iterations.length - 1);

            expect($(selector(START_DATE_ID)).val()).toEqual("");
            expect($(selector(END_DATE_ID)).val()).toEqual("");
        });

        it("should load initial range from date inputs", function(){
            $(selector(START_DATE_ID)).val("2012/01/15");
            $(selector(END_DATE_ID)).val("2012/02/15");

            TrackerStats.setup_iterations_slider(selector(SLIDER_ID),
                selector(START_DATE_ID), selector(END_DATE_ID));

            expect(slider.slider("values", 0)).toBe(1, "start slider is incorrect");
            expect(slider.slider("values", 1)).toBe(2, "finish slider is incorrect");

        });

        it("should load the correct range if dates match iteration edges", function(){
            $(selector(START_DATE_ID)).val(iterations[1]);
            $(selector(END_DATE_ID)).val(iterations[3]);

            TrackerStats.setup_iterations_slider(selector(SLIDER_ID),
                selector(START_DATE_ID), selector(END_DATE_ID));

            expect(slider.slider("values", 0)).toBe(1, "start slider is incorrect");
            expect(slider.slider("values", 1)).toBe(2, "finish slider is incorrect");
        });

    });

});