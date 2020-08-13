# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE), not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  is_test_account        :boolean          default(FALSE)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  tokens                 :text
#  uid                    :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :bigint
#
# Indexes
#
#  index_users_on_email                              (email) UNIQUE
#  index_users_on_invitation_token                   (invitation_token) UNIQUE
#  index_users_on_invitations_count                  (invitations_count)
#  index_users_on_invited_by_id                      (invited_by_id)
#  index_users_on_invited_by_type_and_invited_by_id  (invited_by_type,invited_by_id)
#  index_users_on_reset_password_token               (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider                   (uid,provider) UNIQUE
#
class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable,
         :rememberable, :trackable, :invitable, invite_for: 1.week
  include DeviseTokenAuth::Concerns::User

  include UsersService

  has_many :users_lists, dependent: :destroy
  has_many :lists, through: :users_lists, source: :list, dependent: :restrict_with_exception
  has_many :invitations, class_name: to_s, as: :invited_by, dependent: :restrict_with_exception
  has_many :book_list_items, dependent: :restrict_with_exception
  has_many :grocery_list_items, dependent: :restrict_with_exception
  has_many :music_list_items, dependent: :restrict_with_exception
  has_many :simple_list_items, dependent: :restrict_with_exception
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
    not_completed_lists = List.find_by_sql(not_completed_accepted_lists_query(id))
    completed_lists = List.find_by_sql(limited_completed_accepted_lists_query(id))
    { not_completed_lists: not_completed_lists, completed_lists: completed_lists }
  end

  def pending_lists
    List.find_by_sql(pending_lists_query(id))
  end

  def write_lists
    List.find_by_sql(write_lists_query(id))
  end
end
