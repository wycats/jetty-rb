require 'helper'
require 'fixtures'

Env = EnvGenerator.env_for(2, '/account/credit_card/1')

Routes = OptimizedBasicSet
Routes.call(Env[0])

profile_all(:profile) do
  Routes.call(Env[1])
end
