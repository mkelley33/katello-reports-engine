require 'ui_alchemy-rails'

module Rollup
  class Engine < ::Rails::Engine
    isolate_namespace Rollup

    initializer "rollup.assets.paths", :group => :all do |app|
      app.config.assets.paths << Rollup::Engine.root.join('app', 'assets')
      app.config.assets.paths << Rollup::Engine.root.join('vendor', 'assets', 'components')
      app.config.assets.paths << Rollup::Engine.root.join('vendor', 'assets', 'components', 'font-awesome')

      # Slight hack due to how import loading of SCSS looks up paths
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-forms"
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-buttons"

      app.middleware.use ::ActionDispatch::Static, "#{root}/app/assets/rollup"

      app.config.assets.precompile << proc do |path|
        full_path = Rails.application.assets.resolve(path).to_path
        if path =~ /\.(css|js)\z/
          if full_path.include?("rollup.js")
            puts "Including Rollup master JS file"
            true
          elsif full_path.include?("rollup.scss")
            puts "Including Rollup master CSS file"
            true
          else
            false
          end
        else
          false
        end
      end

    end
  end
end
