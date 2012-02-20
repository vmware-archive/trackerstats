require 'spec_helper'

describe "projects/show" do
  NUMBER_OF_CHARTS = 7

  let(:chart) { mock(:chart, :to_js => '') }
  let(:charts) {
    result = []
    (0..NUMBER_OF_CHARTS).each do |i|
      name = "chart_#{i}"
      result << mock(name, :to_js =>'', description: "##{name} description")
    end
    result
  }
  let(:project) { FactoryGirl.build :project }

  before do
    assign :project, project
    assign :story_type_chart, chart
    assign :velocity_range_chart, mock(to_js: '', description: "#velocity-range-chart description")
    assign :charts, charts
  end

  it "should render 8 charts and its descriptions" do
    render
    chart_selectors = ['#velocity-range-chart']
    (0..NUMBER_OF_CHARTS).each { |chart_number|
      chart_selectors << "#chart_#{chart_number}"
    }
    chart_selectors.each { |chart_selector|
      rendered.should have_css(chart_selector)
      rendered.should have_css("#{chart_selector} div.tooltip_hotspot")
      rendered.should have_css("#{chart_selector} div.tooltip", text: "#{chart_selector} description")
    }
  end

  it "should have a slider for choosing the iteration range" do
    render
    rendered.should have_css("div#iteration-range")
    rendered.should have_css("div#velocity-range-chart")
  end

end
