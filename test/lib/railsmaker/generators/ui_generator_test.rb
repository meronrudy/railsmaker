require 'test_helper'

class UiGeneratorTest < Rails::Generators::TestCase
  include GeneratorHelper

  tests RailsMaker::Generators::UiGenerator
  destination File.expand_path('../../tmp', __dir__)

  def teardown
    FileUtils.rm_rf(destination_root)
    super
  end

  def test_ui_generator_adds_seo_capabilities
    assert_generator_git_commit 'Add sample UI layer'
    RailsMaker::Generators::BaseGenerator.any_instance.expects(:rails_command).with('sitemap:install')

    run_generator ['example.com', 'MyApp']

    assert_file 'Gemfile' do |content|
      assert_match(/gem "sitemap_generator", "6\.3\.0"/, content)
    end

    assert_file 'Dockerfile' do |content|
      assert_match(/# Generate sitemap/, content)
      assert_match(/RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails sitemap:refresh/, content)
    end
  end

  def test_ui_generator_copies_views_and_assets
    run_generator ['example.com', 'MyApp']

    assert_directory 'app/views'
    assert_directory 'app/assets/images'
    assert_directory 'app/controllers'
    assert_directory 'app/helpers'
    assert_directory 'app/javascript'
    assert_directory 'public'

    assert_file 'app/views/shared/_structured_data.html.erb'
    assert_file 'public/robots.txt'
    assert_file 'config/sitemap.rb'
  end

  def test_ui_generator_adds_routes
    run_generator ['example.com', 'MyApp']

    assert_file 'config/routes.rb' do |content|
      assert_match(/get "demo", to: "demo#index", as: :demo/, content)
      assert_match(/get "analytics", to: "demo#analytics", as: :analytics/, content)
      assert_match(/get "support", to: "demo#support", as: :support/, content)
      assert_match(/get "privacy", to: "pages#privacy", as: :privacy/, content)
      assert_match(/get "terms", to: "pages#terms", as: :terms/, content)
    end
  end

  def test_ui_generator_with_duplicate_files
    run_generator ['example.com', 'MyApp']
    run_generator ['example.com', 'MyApp']
    # Ensure no duplicate routes
    assert_file 'config/routes.rb' do |content|
      assert_equal content.scan(/get "demo", to: "demo#index", as: :demo/).size, 1
    end
    # Ensure no duplicate asset files
    assert_file 'public/robots.txt'
  end

  def test_ui_generator_creates_git_commit
    assert_generator_git_commit('Add sample UI layer')
    run_generator ['example.com', 'MyApp']
  end
end
