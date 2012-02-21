require 'spec_helper'

describe "Setting the API token" do

  let(:projects) { FactoryGirl.build_list :project, 3 }

  context "logged out user" do
    it "should not show logout link" do
      visit root_path
      page.should_not have_css("a[href='#{logout_path}']")
    end

    it "should login with API key" do
      log_in_with_api_token projects

      current_path.should == projects_path

      projects.each do |p|
        page.should have_content(p.name)
      end
    end

    it "should be redirected to the login page when accessing projects" do
      visit projects_path
      current_path.should == login_path
    end
  end

  context "logged in user" do
    before do
      log_in_with_api_token projects
    end

    it "can logout" do
      page.should have_css("a[href='#{logout_path}']")
      click_link 'Logout'
      current_path == login_path
      page.should have_content('Successfully logged out.')
    end

    it "can visit the projects listing" do
      visit projects_path
      current_path.should == projects_path
    end

    it "should be redirected to projects page when accessing root" do
      visit root_path
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
        (0..4).each { |i| page.should have_css("#chart_#{i}") }
      end

      it "should have valid chart descriptions" do
        page.should_not have_content('translation missing')
      end

      it "has a iteration range slider", js: true do
        page.should have_css(".ui-slider-range")
      end

      it "has story type filter", true do
        page.find("input#feature")['checked'].should be_true
        page.find("input#bug")['checked'].should be_true
        page.find("input#chore")['checked'].should be_false
      end

      it "uses nice date pickers", js: true do
        class_name = "hasDatepicker"
        page.should have_css("#start_date.#{class_name}")
        page.should have_css("#end_date.#{class_name}")
      end

      it "displays a tooltip when the tooltip hotspot is hovered", js: true do
        page.should have_selector('#chart_0 div.tooltip', visible: false)

        page.evaluate_script("(function(){$('#chart_0 div.tooltip_hotspot').trigger('mouseover'); return true;})()")

        page.should have_selector('#chart_0 div.tooltip', visible: true)
      end

    end

    describe  "iteration range slider" do

      let(:project) { projects.first }

      before do
        Project.stub(:find => project)
        project.stub(:iterations).and_return(FactoryGirl.build_list :iteration_with_stories, 5)
        stories = []

        project.iterations.each do |it|
          stories += it.stories
        end

        project.stub(:stories).and_return(stories)
      end

      it "should correctly render after post when both scrubbers are set at the minimum value", js: true do
        visit project_path(project.id)

        page.evaluate_script("(function(){$('#iteration-range').slider('option', 'values', [0, 0]);return true;})()")
        click_button "Refresh Charts"
        page.evaluate_script("$('#iteration-range').slider('option', 'values')").should == [0, 0]
      end

      it "should correctly render after post when both scrubbers are set at the maximum value", js: true do
        visit project_path(project.id)

        page.evaluate_script("(function(){$('#iteration-range').slider('option', 'values', [5, 5]);return true;})()")
        click_button "Refresh Charts"
        page.evaluate_script("$('#iteration-range').slider('option', 'values')").should == [5, 5]
      end
    end


  end

end

def log_in_with_api_token(stub_projects = [])
  RestClient.stub(:get)
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
