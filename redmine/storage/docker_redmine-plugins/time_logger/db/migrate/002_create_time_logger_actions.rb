class CreateTimeLoggerActions < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def self.up
    create_table :time_logger_actions do |t|
      t.column :user_id, :integer
      t.column :issue_id, :integer
      t.column :time, :datetime
      t.column :action, :string
    end
  end

  def self.down
    drop_table :time_logger_actions
  end
end