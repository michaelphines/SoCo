namespace :db do
  desc "Saves a database table to a yaml fixture"
  task :save_table_to_fixture => :environment do
    unless ENV['TABLE']
      raise "Please specify a table via the TABLE environment variable"
    end
    ActiveRecord::Migration.save_table_to_fixture(ENV['TABLE'], ENV['VERSION']) 
  end

  desc "Restores a database table from a yaml fixture"
  task :restore_table_from_fixture => :environment do
    unless ENV['TABLE']
      raise "Please specify a table via the TABLE environment variable"
    end
    ActiveRecord::Migration.restore_table_from_fixture(ENV['TABLE'], ENV['VERSION']) 
  end
end