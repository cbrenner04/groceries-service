# frozen_string_literal: true

# sends event based emails to participants
class SharedListNotificationMailer < ApplicationMailer
  def notify(sharer_email, sharee_email)
    @sharer = sharer_email
    @url = root_url
    mail(to: sharee_email, subject: I18n.t("shared_list_mailer_subject"))
  end
end
