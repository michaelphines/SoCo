class ZeroFillCourseNumber < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `cis_courses` CHANGE `number` `number` INT( 3 ) UNSIGNED ZEROFILL NOT NULL"
  end

  def self.down
    execute "ALTER TABLE `cis_courses` CHANGE `number` `number` INT( 3 ) NOT NULL"
  end
end
