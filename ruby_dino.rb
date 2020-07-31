# Our company recently acquired a new company that had a very large dinosaur population (for a very low price...)
# We need to send these recently imported users (who have many dinos) a welcome email that 
# has a reset password token, to their new user accounts in our system.
# One caveat is that we have to send them in small bathces, so our email doesn't get blacklisted.
# We will send a batch of emails and wait every 10 minutes before we send another batch out.
# Given the following (not so great 🤓) code, please refactor this how you best see fit, without changing the behavior of the code. 

require 'byebug'
require_relative '../app/boot'
include DinoTools
require 'csv'
require 'lib/dino_tools/welcome_users'

def recently_imported_user_ids
  DB[:new_dinos_users].where(
    DB[:dinosaurs].where(
      creator_id: :new_dinos__user_id).exists).exclude(user_id: DB[:event_notifications].where(
    name: 'special_welcome').select(:user_id)).distinct
end

notifier = DinoTools::WelcomeUsers.new(recently_imported_user_ids)
notifier.notify_all