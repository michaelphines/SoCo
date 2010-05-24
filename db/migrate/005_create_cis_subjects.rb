class CreateCisSubjects < ActiveRecord::Migration
  def self.up
    create_table :cis_subjects do |t|
      t.column "code", :string, :limit => 6, :default => "", :null => false
    end

    add_index :cis_subjects, ["code"], :name => "code", :unique => true
  end

  def self.down
    drop_table :cis_subjects
  end
end
