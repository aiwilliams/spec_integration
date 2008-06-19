require 'spec/rake/spectask'

namespace :spec do
  desc "Runs integration specs in spec/integration"
  Spec::Rake::SpecTask.new(:integration) do |t|
    t.spec_files = FileList["spec/integration/**/*_spec.rb"]
  end
end
