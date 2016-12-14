require "rails_helper"

module Api
  module V1
    module Users
      RSpec.describe SessionsController do

        before do
          # This is required because we are bypassing the router to test custom
          # logic in the devise controller methods
          @request.env["devise.mapping"] = Devise.mappings[:user]
        end

        describe "#create" do
          context "with an existing user" do
            let!(:user) { User.create(email: "first@gmail.com", password: "password") }

            context "and valid login params" do
              let(:params) {{
                user: {
                  email: user.email,
                  password: "password"
                },
                format: :json
              }}
              let(:jwt_mock) { double ApplicationController }
              let(:successful_response) { { status: "success" }.to_json }

              before do
                expect(controller)
                  .to receive(:payload)
                  .and_return(jwt_mock)
                expect(jwt_mock)
                  .to receive(:to_json)
                  .and_return(successful_response)
              end

              it "signs in the user" do
                post :create, params: params
                user.reload
                expect(user.current_sign_in_at).to be_truthy
              end

              it "returns a status of 201" do
                post :create, params: params
                expect(response).to have_http_status 201
              end

              it "initializes user presenter and renders the value of .to_json" do
                post :create, params: params
                expect(response.body).to eq successful_response
              end
            end

            context "and invalid login params" do
              let(:params) {{
                user: {
                  email: user.email,
                  password: "wrong_password"
                },
                format: :json
              }}

              it "does not sign in the user" do
                post :create, params: params
                user.reload
                expect(user.current_sign_in_at).to be_falsy
              end

              it "returns an error with a status 401" do
                post :create, params: params
                expect(response).to have_http_status 401
                body = JSON.parse(response.body).with_indifferent_access
                expect(body[:error]).to eq "Invalid Email or password."
              end
            end

            context "with an email that doesn't belong to an existing user" do
              context "and valid login params" do
                let(:params) {{
                  user: {
                    email: "unique_email@gmail.com",
                    password: "password"
                  },
                  format: :json
                }}

                it "does not create a new user" do
                  expect {
                    post :create, params: params
                  }.not_to change {
                    User.count
                  }
                end

                it "returns a status 401" do
                  post :create, params: params
                  expect(response).to have_http_status 401
                end

                it "returns an error with a status 401" do
                  post :create, params: params
                  expect(response).to have_http_status 401
                  body = JSON.parse(response.body).with_indifferent_access
                  expect(body[:error]).to eq "Invalid Email or password."
                end
              end

              context "and invalid login parameter" do
                context "email" do
                  let(:params) {{
                    user: {
                      email: "bad",
                      password: "password"
                    },
                    format: :json
                  }}

                  it "does not create a new user" do
                    expect {
                      post :create, params: params
                    }.not_to change {
                      User.count
                    }
                  end

                  it "returns a status 401" do
                    post :create, params: params
                    expect(response).to have_http_status 401
                  end

                  it "returns an error with a status 401" do
                    post :create, params: params
                    expect(response).to have_http_status 401
                    body = JSON.parse(response.body).with_indifferent_access
                    expect(body[:error]).to eq "Invalid Email or password."
                  end
                end

                context "password" do
                  let(:params) {{
                    user: {
                      email: user.email,
                      password: "almost"
                    },
                    format: :json
                  }}

                  it "does not create a new user" do
                    expect {
                      post :create, params: params
                    }.not_to change {
                      User.count
                    }
                  end

                  it "returns a status 401" do
                    post :create, params: params
                    expect(response).to have_http_status 401
                  end

                  it "returns an error with a status 401" do
                    post :create, params: params
                    expect(response).to have_http_status 401
                    body = JSON.parse(response.body).with_indifferent_access
                    expect(body[:error]).to eq "Invalid Email or password."
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end