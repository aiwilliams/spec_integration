# In rails 1.2, plugins aren't available in the path until they're loaded.
# Check to see if the rspec plugin is installed first and require
# it if it is.  If not, use the gem version.
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)

require 'spec/rake/spectask'

namespace :spec do
  desc "Runs integration specs in spec/integration"
  Spec::Rake::SpecTask.new(:integration) do |t|
    t.spec_files = FileList["spec/integration/**/*_spec.rb"]
  end
end
