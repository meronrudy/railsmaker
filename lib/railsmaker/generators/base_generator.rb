module RailsMaker
  module Generators
    class BaseGenerator < Rails::Generators::Base
      include Rails::Generators::Actions
    end
  end
end
