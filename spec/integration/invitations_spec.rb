# frozen_string_literal: true

require "rails_helper"

describe "/auth/invitation", type: :request do
  let(:user) { create :user_with_lists }
  let(:list) { user.lists.last }

  before { login user }

  describe "POST /" do
    context "when list_id param exists" do
      context "with valid params" do
        it "creates a new user" do
          starting_user_count = User.count
          starting_users_list_count = UsersList.count
          post auth_invitation_path,
               params: {
                 email: "foo@bar.com",
                 list_id: list.id
               },
               headers: auth_params

          new_user = User.find_by(email: "foo@bar.com")
          new_users_list =
            UsersList.find_by(user_id: new_user.id, list_id: list.id)
          response_body = JSON.parse(response.body).to_h

          expect(User.count).to be starting_user_count + 1
          expect(UsersList.count).to be starting_users_list_count + 1
          expect(response).to have_http_status :created
          expect(response_body["user"]).to eq(
            "id" => new_user[:id],
            "email" => new_user[:email],
            "created_at" => new_user[:created_at].iso8601(3),
            "updated_at" => new_user[:updated_at].iso8601(3),
            "is_test_account" => new_user[:is_test_account],
            "provider" => "email",
            "uid" => new_user[:email],
            "allow_password_change" => false
          )
          expect(response_body["users_list"]).to eq(
            "id" => new_users_list[:id],
            "permissions" => new_users_list[:permissions]
          )
        end
      end

      context "with invalid params" do
        it "responds with errors" do
          post auth_invitation_path,
               params: {
                 email: nil,
                 list_id: list.id
               },
               headers: auth_params

          expect(response).to have_http_status :unprocessable_entity
          expect(response.body).to eq("{\"email\":[\"can't be blank\"]}")
        end
      end

      describe "when user already exists" do
        context "when users_list already exists" do
          it "does not create a new users_list and responds with errors" do
            other_user = create :user
            create :users_list, user: other_user, list: list
            expect do
              post auth_invitation_path,
                   params: {
                     email: other_user.email,
                     list_id: list.id
                   },
                   headers: auth_params
            end.not_to change(UsersList, :count)
            response_body = JSON.parse(response.body).to_h

            expect(response).to have_http_status :conflict
            expect(response_body["responseText"]).to eq(
              "List already shared with #{other_user.email}"
            )
          end
        end

        context "when users_list does not already exist" do
          it "does not create a new user, creates a new users_list" do
            other_user = create :user
            starting_user_count = User.count
            starting_users_list_count = UsersList.count
            post auth_invitation_path,
                 params: {
                   email: other_user.email,
                   list_id: list.id
                 },
                 headers: auth_params

            new_users_list =
              UsersList.find_by(user_id: other_user.id, list_id: list.id)
            response_body = JSON.parse(response.body).to_h

            expect(User.count).to be starting_user_count
            expect(UsersList.count).to be starting_users_list_count + 1
            expect(response).to have_http_status :created
            expect(response_body["user"]).to eq(
              "id" => other_user[:id],
              "email" => other_user[:email],
              "created_at" => other_user[:created_at].iso8601(3),
              "updated_at" => other_user[:updated_at].iso8601(3),
              "is_test_account" => other_user[:is_test_account],
              "provider" => "email",
              "uid" => other_user[:email],
              "allow_password_change" => false
            )
            expect(response_body["users_list"]).to eq(
              "id" => new_users_list[:id],
              "permissions" => new_users_list[:permissions]
            )
          end
        end
      end
    end

    context "when list_id param does not exist" do
      context "with valid params" do
        context "when user does not already exist" do
          it "creates a new user, does not create a users list" do
            starting_user_count = User.count
            starting_users_list_count = UsersList.count
            post auth_invitation_path,
                 params: {
                   email: "foo@bar.com"
                 },
                 headers: auth_params

            new_user = User.find_by(email: "foo@bar.com")
            new_users_list =
              UsersList.find_by(user_id: new_user.id, list_id: list.id)
            response_body = JSON.parse(response.body).to_h

            expect(User.count).to be starting_user_count + 1
            expect(UsersList.count).to be starting_users_list_count
            expect(new_users_list).to be_nil
            expect(response).to have_http_status :created
            expect(response_body["user"]).to eq(
              "id" => new_user[:id],
              "email" => new_user[:email],
              "created_at" => new_user[:created_at].iso8601(3),
              "updated_at" => new_user[:updated_at].iso8601(3),
              "is_test_account" => new_user[:is_test_account],
              "provider" => "email",
              "uid" => new_user[:email],
              "allow_password_change" => false
            )
            expect(response_body["users_list"]).to be_nil
          end
        end

        context "when user does already exist" do
          it "responds with ok" do
            user_email = "foo@bar.com"
            User.create!(email: user_email)
            post auth_invitation_path,
                 params: {
                   email: user_email
                 },
                 headers: auth_params
            expect(response).to have_http_status :ok
          end
        end
      end

      context "with invalid params" do
        it "responds with errors" do
          post auth_invitation_path,
               params: {
                 email: nil
               },
               headers: auth_params

          expect(response).to have_http_status :unprocessable_entity
          expect(response.body).to eq("{\"email\":[\"can't be blank\"]}")
        end
      end
    end
  end

  describe "PUT /" do
    let(:new_user) { User.invite!(email: "test@test.org") }

    context "with invalid token" do
      it "responds with errors" do
        put auth_invitation_path,
            params: {
              password: "foobar",
              password_confirmation: "foobar",
              invitation_token: "foobar"
            }

        expect(response).to have_http_status :unprocessable_entity
        expect(response.body).to eq(
          "{\"errors\":[\"Invitation token is invalid\"]}"
        )
      end
    end

    context "with valid token" do
      context "with valid params" do
        it "updates user" do
          put auth_invitation_path,
              params: {
                password: "foobar",
                password_confirmation: "foobar",
                invitation_token: new_user.raw_invitation_token
              }
          new_user.reload

          expect(response).to have_http_status :accepted
        end
      end

      context "with invalid params" do
        it "responds with errors" do
          put auth_invitation_path,
              params: {
                password: "foobar",
                password_confirmation: "foobaz",
                invitation_token: new_user.raw_invitation_token
              }

          expect(response).to have_http_status :unprocessable_entity
          expect(response.body).to eq("{\"errors\":\"password and password " \
                                      "confirmation must be the same\"}")
        end
      end
    end
  end
end
