require 'spec_helper'

describe "Setting the API token" do

  let(:projects) { FactoryGirl.build_list :project, 3 }

  context "logged out user" do
    it "sets the API token directly" do
      log_in_with_api_token projects

      current_path.should == projects_path

      projects.each do |p|
        page.should have_content(p.name)
      end
    end
  end

  context "logged in user" do
    before do
      log_in_with_api_token projects
    end

    it "can visit the projects listing" do
      visit projects_path
      current_path.should == projects_path
    end

    context "at the project charts page" do

      let(:project) { projects.first }

      before do
        Project.should_receive(:find).and_return(project)
        project.stub(:iterations).and_return([])
        project.stub(:stories).and_return([])
        visit project_path(project.id)
      end

      it "can see the project charts" do
        page.should have_css("#story_type_chart")
        (0..6).each { |i| page.should have_css("#chart_#{i}") }
      end

      it "has a iteration range slider", js: true do
        page.should have_css(".ui-slider-range")
      end

      it "uses nice date pickers", js: true do
        class_name = "hasDatepicker"
        page.should have_css("#start_date.#{class_name}")
        page.should have_css("#end_date.#{class_name}")
      end

    end


  end

end

def log_in_with_api_token(stub_projects = [])
  stub_request(:get, "https://www.pivotaltracker.com/services/v3/projects.xml")
    .with(:headers => { 'X-Trackertoken'=>'faker_token' })
    .to_return(:status => 200, :body => projects_index_xml(stub_projects), :headers => {})

  visit "/"

  within "#via_api_token" do
    fill_in "API Token", with: "faker_token"
    click_button "Retrieve Projects"
  end
end

def projects_index_xml(projects)
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.projects(type: "array") {
      projects.each do |project|
        xml.project {
          xml.id project.id
          xml.name project.name
        }
      end
    }
  end
  builder.to_xml
end

#describe "the project details page" do
#
#  before do
#    #session[:api_token] = "stubby_token"
#    page.set_rack_session(:api_token => "stubby_token")
#    visit '/projects/72'
#  end
#
#
#end
