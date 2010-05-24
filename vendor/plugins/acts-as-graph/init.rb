# puts "require path:\n"
# puts ($:).to_yaml

require 'acts_as_graph'

# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
ActiveRecord::Base.send(:include, TammerSaleh::Acts::Graph)

