require 'spec_helper'

describe SessionsController do
  describe "#create" do
    def do_request
      post :create, params
    end

    let(:api_token) { "12345678xxx" }

    context "via username and password" do
      let(:username) { "winston" }
      let(:password) { "jollygoodfellow" }
      let(:params)   { { username: username, password: password } }

      it "sessionizes API Token" do
        PivotalTracker::Client.should_receive(:token).with(username, password).and_return(api_token)
        do_request

        session[:api_token].should == api_token
        response.should redirect_to projects_path
      end
    end

    context "via api token" do
      let(:params) { { api_token: api_token } }

      it "sessionizes API Token" do
        do_request

        session[:api_token].should == api_token
        response.should redirect_to projects_path
      end
    end

    context "failure" do
      let(:params) { {} }

      it "redirects to root with flash" do
        do_request

        response.should redirect_to root_path
        flash[:alert].should == "We were not able to authenticate you lah."
      end
    end
  end
end
