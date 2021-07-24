class TimeLoggerAction < ActiveRecord::Base
  belongs_to :user
  has_one :issue

  def initialize(arguments = nil)
    super(arguments)
    self.user_id = User.current.id
    self.time = DateTime.now
  end

end
