# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

ManualsFrontend::Application.load_tasks

task default: [:lint, :spec, "jasmine:ci"]
