class EmailAddressFilter
  def self.delivering_email(message)
    if message.to.first.include?("example.com")
      message.perform_deliveries = false
    end
  end
end

ActionMailer::Base.register_interceptor(EmailAddressFilter)
