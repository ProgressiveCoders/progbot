class ImportUsersJob < ApplicationJob
  queue_as :default

  def perform()
    print "job"
  end
end
