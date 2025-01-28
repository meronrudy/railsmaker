# frozen_string_literal: true

module RailsMaker
  module Generators
    class BaseGenerator < Rails::Generators::Base
      include Rails::Generators::Actions
      include GsubValidation
    end
  end
end
