# if the environment includes the `minitest` gem, them loading +minitest+ fails
# weirdly since it is not part of Ruby itself. Therefore, the safest approach (as
# Rails uses the external gem) is to require it as a gem dependency, avoiding load
# conflicts.
gem "minitest"

require "minitest/autorun"
require "cubic"
