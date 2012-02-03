require "spec_helper"

describe "projects/index.html.haml" do

  it "renders" do
    assign :projects, FactoryGirl.build_list(:project, 4)
    render
  end

end