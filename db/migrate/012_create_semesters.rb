class CreateSemesters < ActiveRecord::Migration
  def self.up
    create_table :semesters do |t|
      t.column "user_id",  :integer,                            :null => false
      t.column "year",     :integer, :limit => 4,               :null => false
      t.column "semester", :enum,    :limit => [:SP, :SU, :FA], :null => false
    end
  end

  def self.down
    drop_table :semesters
  end
end
