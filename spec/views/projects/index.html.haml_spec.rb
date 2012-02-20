require "spec_helper"

describe "projects/index" do

  it "renders" do
    assign :projects, FactoryGirl.build_list(:project, 4)
    render
    rendered.should have_css("ul")
  end

end
