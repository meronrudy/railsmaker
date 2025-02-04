# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'

  add_group 'Generators', 'lib/railsmaker/generators'
  add_group 'Core', 'lib/railsmaker'
end

require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/minitest'
require 'railsmaker'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Load all support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |f| require f }
