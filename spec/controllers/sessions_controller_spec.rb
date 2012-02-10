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
        stub_request(:post, 'https://www.pivotaltracker.com/services/v3/tokens/active')
            .with(body: { username: username, password: password })
            .to_return(body: "<guid>#{api_token}</guid>")

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

  describe "#destroy" do
    it "should remove the api token from the session on logout and redirect to root" do
      session[TrackerApi::API_TOKEN_KEY] = 'API_TOKEN_SET'
      delete :destroy
      session[TrackerApi::API_TOKEN_KEY].should be_nil
      response.should redirect_to login_path
    end
  end

end
