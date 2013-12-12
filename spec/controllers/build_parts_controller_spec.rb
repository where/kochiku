require 'spec_helper'

describe BuildPartsController do
  include ControllerHelper
  render_views

  describe "#show" do
    it "renders the show template successfully even if elapsed time is nil" do
      project = FactoryGirl.create(:big_rails_project)
      build = FactoryGirl.create(:build, :project => project)
      build_part = build.build_parts.create!(:paths => ["a"], :kind => "test", :queue => :ci)
      build_part.elapsed_time.should == nil
      get :show, :project_id => project.to_param, :build_id => build.to_param, :id => build_part.to_param
      response.should be_success
      response.should render_template("build_parts/show")
    end
  end

  describe "the #api method" do
    context "#show response" do
      it "includes the last build_attempt" do
        project = FactoryGirl.create(:big_rails_project)
        build = FactoryGirl.create(:build, :project => project)
        build_part = build.build_parts.create!(:paths => ["a"], :kind => "test", :queue => :ci)
        build_attempt = FactoryGirl.create(:build_attempt, :build_part => build_part)
        expect = build_part.as_json.merge!(:last_build_attempt => build_attempt.as_json)
        build_part.elapsed_time.should == nil
        get :show, :format => :json, :project_id => project.to_param, :build_id => build.to_param, :id => build_part.to_param
        response.should be_success
        json_response['build_part'].should include('last_build_attempt')
      end
    end
  end
end
