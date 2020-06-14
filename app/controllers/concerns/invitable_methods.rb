# frozen_string_literal: true

# methods used in users/invitations_controller.rb
module InvitableMethods
  extend ActiveSupport::Concern

  # this is needed for the create method in users/invitations_controller.rb
  def resource_class(map = nil)
    mapping = if map
                Devise.mappings[map]
              else
                Devise.mappings[resource_name] || Devise.mappings.values.first
              end
    mapping.to
  end
end
