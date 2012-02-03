require 'spec_helper'

describe "projects/show.html.haml" do

  let(:chart) { mock(:chart, :to_js => '' ) }
  let(:project) { FactoryGirl.build :project }

  #let(:iterations) {
  #  [
  #      FactoryGirl.build(:iteration_with_stories),
  #      FactoryGirl.build(:iteration_with_stories),
  #      FactoryGirl.build(:iteration_with_stories),
  #  ]
  #}
  #
  #let(:stories) {
  #  all_stories = []
  #  iterations.each do |iteration| all_stories += iteration.stories end
  #  all_stories
  #}

  before do
    assign :project, project
    assign :story_type_chart, chart
    assign :velocity_range_chart, mock(to_js: '')
  end

  it "should render" do
    render
  end

  it "should have a slider for choosing the iteration range" do
    render
    rendered.should have_css("div#iteration-range")
    rendered.should have_css("div#velocity-range-chart")
  end

end
