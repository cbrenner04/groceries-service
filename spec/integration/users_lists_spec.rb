# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/users_lists", type: :request do
  let(:user) { create :user_with_lists }
  let(:list) { user.lists.last }
  let(:users_list) { list.users_lists.find_by(user: user) }
  let(:other_user) { create :user }
  let(:third_user) { create :user }

  before { login user }

  describe "GET /" do
    describe "with read access" do
      before { list.users_lists.delete_all }

      it "responds with forbidden" do
        get list_users_lists_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      it "responds with success and correct payload" do
        UsersList.create(user: other_user, list: list)
        UsersList.create(user: third_user, list: list, has_accepted: false)

        get list_users_lists_path(list.id), headers: auth_params

        expect(response).to have_http_status :success
        response_body = JSON.parse(response.body)
        expect(response_body["list"].to_h).to include(
          "id" => list[:id],
          "name" => list[:name],
          "archived_at" => list[:archived_at],
          "completed" => list[:completed],
          "refreshed" => list[:refreshed]
        )
        expect(response_body["accepted"].count).to eq 1
        expect(response_body["invitable_users"].count).to eq 0
        expect(response_body["pending"].count).to eq 1
        expect(response_body["refused"].count).to eq 1
        expect(response_body["current_user_id"]).to eq user.id
        expect(response_body["user_is_owner"]).to eq false
      end
    end
  end

  describe "PATCH /;id" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      context "when users_list exists" do
        it "accepts list" do
          patch list_users_list_path(list.id, users_list.id),
                params: {
                  users_list: {
                    has_accepted: true
                  }
                },
                headers: auth_params

          users_list = JSON.parse(response.body)
          expect(users_list["has_accepted"]).to eq true
        end

        it "rejects list" do
          patch list_users_list_path(list.id, users_list.id),
                params: {
                  users_list: {
                    has_accepted: false
                  }
                },
                headers: auth_params

          users_list = JSON.parse(response.body)
          expect(users_list["has_accepted"]).to eq false
        end

        describe "permissions" do
          context "with good data" do
            it "updates permissions" do
              patch list_users_list_path(list.id, users_list.id),
                    params: {
                      users_list: {
                        permissions: "read"
                      }
                    },
                    headers: auth_params

              users_list = JSON.parse(response.body)
              expect(users_list["permissions"]).to eq "read"
            end
          end

          context "with bad data" do
            it "returns 422" do
              patch list_users_list_path(list.id, users_list.id),
                    params: {
                      users_list: {
                        permissions: "foo"
                      }
                    },
                    headers: auth_params

              expect(response.status).to eq 422
            end
          end
        end
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      context "when users_list exists" do
        it "accepts list" do
          patch list_users_list_path(list.id, users_list.id),
                params: {
                  users_list: {
                    has_accepted: true
                  }
                },
                headers: auth_params

          users_list = JSON.parse(response.body)
          expect(users_list["has_accepted"]).to eq true
        end

        it "rejects list" do
          patch list_users_list_path(list.id, users_list.id),
                params: {
                  users_list: {
                    has_accepted: false
                  }
                },
                headers: auth_params

          users_list = JSON.parse(response.body)
          expect(users_list["has_accepted"]).to eq false
        end

        describe "permissions" do
          context "with good data" do
            it "updates permissions" do
              patch list_users_list_path(list.id, users_list.id),
                    params: {
                      users_list: {
                        permissions: "read"
                      }
                    },
                    headers: auth_params

              users_list = JSON.parse(response.body)
              expect(users_list["permissions"]).to eq "read"
            end
          end

          context "with bad data" do
            it "returns 422" do
              patch list_users_list_path(list.id, users_list.id),
                    params: {
                      users_list: {
                        permissions: "foo"
                      }
                    },
                    headers: auth_params

              expect(response.status).to eq 422
            end
          end
        end
      end
    end
  end

  describe "POST /" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        post list_users_lists_path(list.id),
             params: {
               users_list: {
                 user_id: other_user.id,
                 list_id: list.id
               }
             },
             headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      describe "with valid params" do
        it "creates a new users list" do
          expect do
            post list_users_lists_path(list.id),
                 params: {
                   users_list: {
                     user_id: other_user.id,
                     list_id: list.id
                   }
                 },
                 headers: auth_params
          end.to change(UsersList, :count).by 1
        end
      end

      describe "with invalid params" do
        it "re-renders the 'new' template" do
          post list_users_lists_path(list.id),
               params: {
                 users_list: {
                   user_id: nil
                 }
               },
               headers: auth_params

          expect(response.status).to eq 422
        end
      end
    end
  end
end
