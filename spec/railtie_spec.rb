require 'spec_helper'

RSpec.describe 'Railtie for fix_db_schema_conflicts on db:schema:dump' do
  shared_examples :railtie do |rails_version|
    let(:app_root) { Pathname.new(__dir__).join("test-apps/rails-#{rails_version}-app") }

    def command(cmd, output: Tempfile.new)
      env = { 'RAILS_ENV' => 'development' }
      Bundler.with_clean_env { Kernel.system(env, cmd, out: output) }

      unless $CHILD_STATUS.success?
        output.rewind
        warn output.read
        raise "Command exited with error: #{cmd}"
      end
    ensure
      output.close
      output.unlink
    end

    it 'generates a sorted schema with no extra spacing' do
      FileUtils.rm_f(app_root.join('db/schema.rb'))
      FileUtils.cd(app_root) do
        command('bundle update fix-db-schema-conflicts')
        command('bundle exec rake db:schema:dump')
      end

      expected_schema  = app_root.join('db/schema.expected.rb').read
      generated_schema = app_root.join('db/schema.rb').read

      expect(generated_schema).to eq expected_schema
    end
  end

  context('for Rails 4.1') { include_examples :railtie, '4.1' } if RUBY_VERSION[0,3] == '2.3'
  context('for Rails 4.2') { include_examples :railtie, '4.2' }
  context('for Rails 5.0') { include_examples :railtie, '5.0' }
  context('for Rails 5.1') { include_examples :railtie, '5.1' }
  context('for Rails 5.2') { include_examples :railtie, '5.2' }
end
