namespace :db do
  require 'sequel'

  namespace :migrate do
    Sequel.extension :migration
    DB = Sequel.connect(ENV['EKTRACKER_DB_URL'] || 'postgres://ektracker:test@localhost/ektracker')

    # Handle PostgreSQL enum types.
    DB.extension :pg_enum

    # Drop and recreate all enums
    begin
      DB.create_enum(:ek_type, %w'angler nuclear rig neutrino unknown')
    rescue
    end

    begin
      DB.create_enum(:source, %w'mta unknown')
    rescue
    end

    desc 'Perform a full migration reset (full erase and migration up)'
    task :reset do
      Sequel::Migrator.run(DB, 'lib/ektracker/migrations', :target => 0)
      Sequel::Migrator.run(DB, 'lib/ektracker/migrations')
      puts '<= sq:migrate:reset finished'
    end
  end
end
