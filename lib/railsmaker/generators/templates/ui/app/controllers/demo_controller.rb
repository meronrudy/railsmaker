# frozen_string_literal: true

class DemoController < ApplicationController
  before_action :require_login

  def index; end
end
