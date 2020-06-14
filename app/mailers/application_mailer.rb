# frozen_string_literal: true

# Mailer superclass.
class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@groceries-app.com"
  layout "mailer"
end
