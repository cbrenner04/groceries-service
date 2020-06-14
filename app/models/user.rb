# frozen_string_literal: true

# no doc
class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable,
         :rememberable, :trackable, :invitable, invite_for: 1.week
  include DeviseTokenAuth::Concerns::User

  include UsersService

  has_many :users_lists, dependent: :destroy
  has_many :lists,
           through: :users_lists,
           source: :list,
           dependent: :restrict_with_exception
  has_many :invitations,
           class_name: to_s,
           as: :invited_by,
           dependent: :restrict_with_exception
  has_many :book_list_items, dependent: :restrict_with_exception
  has_many :grocery_list_items, dependent: :restrict_with_exception
  has_many :music_list_items, dependent: :restrict_with_exception
  has_many :to_do_list_items, dependent: :restrict_with_exception

  validates :email, presence: true

  def users_that_list_can_be_shared_with(list)
    User.find_by_sql(related_users_query(id, list.id))
  end

  def current_list_permissions
    current_list_permissions = {}
    users_lists.each do |users_list|
      next if List.find(users_list.list_id).archived_at

      current_list_permissions[users_list.list_id] = users_list.permissions
    end
    current_list_permissions
  end

  def all_completed_lists
    List.find_by_sql(completed_accepted_lists_query(id))
  end

  def accepted_lists
    not_completed_lists =
      List.find_by_sql(not_completed_accepted_lists_query(id))
    completed_lists =
      List.find_by_sql(limited_completed_accepted_lists_query(id))
    {
      not_completed_lists: not_completed_lists,
      completed_lists: completed_lists
    }
  end

  def pending_lists
    List.find_by_sql(pending_lists_query(id))
  end
end
