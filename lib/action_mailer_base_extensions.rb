# Patch ActionMailer to send Notifications of Issue changes only if
# a) Thread.current[:send_notification_email] = true
#    and Thread.current[:is_issue_change] = true
# or
# b) Thread.current[:is_issue_change] = false

module ActionMailerBaseExtensions
  def deliver_with_stealth!(mail=nil)
    mail ||= instance_variable_get(:@mail)
    if (Thread.current[:is_issue_change] && Thread.current[:send_notification_email]) || !Thread.current[:is_issue_change]
      deliver_without_stealth!(mail)
      Thread.current[:send_notification_email] = false
      Thread.current[:is_issue_change] = false
    end
  end
end

module ActionMailer
  class Base
    include ActionMailerBaseExtensions
    alias_method_chain :deliver!, :stealth
  end
end
