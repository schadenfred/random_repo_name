require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/minitest'

require_relative '../lib/dino_tools/welcome_users.rb'

describe DinoTools::WelcomeUsers do 

  let(:user_ids) { Array (1..69) } 
  let(:chunk_of_ids) { Array (1..59) } 
  let(:notifier) { DinoTools::WelcomeUsers.new(user_ids, 1) }
  
  DB = Sequel.mock
    
  describe ".send_welcome_email" do 
    ## Would mock this out if I had time.
  end
  
  describe ".notify(user_id)" do 
    describe "success" do 
      
      it "must increment attempts and total notices" do
        notifier.expects(:send_welcome_email)
        notifier.notify(1)          
        assert_equal notifier.instance_variable_get(:@attempts), 1
        assert_equal notifier.instance_variable_get(:@total_notices_sent), 1
      end
    end
  end 
  
  describe ".notify_all" do 
    describe "success" do
      
      it "notify_all" do 
        notifier.stubs(:send_welcome_email)  
        assert notifier.notify_all
      end
    end
  end
end