# frozen_string_literal: true

# notification for a new lesson plan
class SharedListNotification
  def self.send_notification_for(sharer, sharee_id)
    logger.info "START: shared_list_notification"
    logger.info "sending shared_list_notification to user #{sharee_id}"
    sharee = User.find(sharee_id)
    SharedListNotificationMailer.notify(sharer.email, sharee.email).deliver_now
    logger.info "END: shared_list_notification"
  end

  def self.logger
    Logger.new(STDOUT)
  end
end
