require('/assets/application.js');

describe("TrackerStats", function() {
    describe("#add_datepicker", function() {
        var ID = "my_datepicker";
        var DATEPICKER_CLASS = "hasDatepicker";
        var input;

        beforeEach(function(){
            $("#test").html("<input id='" + ID + "' type='text'/>");
            input = $('#' + ID);
        });


        it("adds a datepicker to the element with the given id", function() {
            expect(input.hasClass(DATEPICKER_CLASS)).toBeFalsy();
            TrackerStats.add_datepicker(ID);
            expect(input.hasClass(DATEPICKER_CLASS)).toBeTruthy();
        });

        it("adds a datepicker with the correct date format", function() {
            TrackerStats.add_datepicker(ID);
            expect(input.datepicker("option", "dateFormat")).toBe("yy/mm/dd");
        });

    });
});