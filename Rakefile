require 'rspec/core/rake_task'

namespace(:test) do
  namespace(:spec) do
    desc 'Run spec tests'
    RSpec::Core::RakeTask.new(:run) do |t|
      t.rspec_opts = ['--color']
      t.pattern = 'spec/'
    end
  end
end

task :test => 'test:spec:run'
