require 'spec_helper'

RSpec.describe 'Railtie for fix_db_schema_conflicts on db:schema:dump' do
  shared_examples :railtie do |rails_version|
    def command(config={}, cmd, output: Tempfile.new)
      env = config.merge('RAILS_ENV' => 'development')

      FileUtils.cd(@app_root) do
        Bundler.with_clean_env { Kernel.system(env, cmd, out: output) }
      end

      unless $CHILD_STATUS.success?
        output.rewind
        warn output.read
        raise "Command exited with error: #{cmd}"
      end
    ensure
      output.close
      output.unlink
    end

    before(:all) do
      @app_root = Pathname.new(__dir__).join("test-apps/rails-#{rails_version}-app")
      command 'bundle update fix-db-schema-conflicts'
    end

    before do
      command 'rm -f db/schema.rb'
      command config, 'bundle exec rake db:schema:dump'
    end

    let(:app_root) { @app_root }
    let(:generated_schema) { app_root.join('db/schema.rb').read }

    context 'with default configs' do
      let(:config) { Hash.new }
      let(:expected_schema) { app_root.join('db/schema.fixed.rb').read }

      it 'generates a sorted, auto-corrected schema' do
        expect(generated_schema).to eq expected_schema
      end
    end

    context 'when DISABLE_SCHEMA_SORT is set' do
      let(:config) { Hash["DISABLE_SCHEMA_SORT" => "true"] }
      let(:expected_schema) { app_root.join('db/schema.only_autocorrected.rb').read }

      it 'generates a schema that is only auto-corrected' do
        expect(generated_schema).to eq expected_schema
      end
    end

    context 'when DISABLE_SCHEMA_AUTOCORRECT is set' do
      let(:config) { Hash["DISABLE_SCHEMA_AUTOCORRECT" => "true"] }
      let(:expected_schema) { app_root.join('db/schema.only_sorted.rb').read }

      it 'generates a schema that is only sorted' do
        expect(generated_schema).to eq expected_schema
      end
    end

    context 'when DISABLE_SCHEMA_FIX is set' do
      let(:config) { Hash["DISABLE_SCHEMA_FIX" => "true"] }
      let(:expected_schema) { app_root.join('db/schema.original.rb').read }

      it 'generates an unmodified schema' do
        expect(generated_schema).to eq expected_schema
      end
    end
  end

  context('for Rails 4.1') { include_examples :railtie, '4.1' } if RUBY_VERSION[0,3] == '2.3'
  context('for Rails 4.2') { include_examples :railtie, '4.2' }
  context('for Rails 5.0') { include_examples :railtie, '5.0' }
  context('for Rails 5.1') { include_examples :railtie, '5.1' }
  context('for Rails 5.2') { include_examples :railtie, '5.2' }
end
