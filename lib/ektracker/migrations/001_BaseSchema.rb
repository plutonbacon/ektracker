Sequel.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'

    create_table(:artifacts) do
      UUID           :uuid,           :primary_key => true,  :default => Sequel.function(:uuid_generate_v4)
      ek_type        :ek_type,        :null => false,        :default => 'unknown'
      String         :mime,           :null => false,        :default => 'unknown'
      source         :source,         :null => false,        :default => 'unknown'
      String         :source_link,    :null => false
      DateTime       :created_at,     :null => false
      DateTime       :updated_at,     :null => false
      String         :fs_path,        :null => false
      String         :md5,            :null => false,        :unique => true
      Integer        :size,           :null => false
    end
  end

  down do
    drop_table(:artifacts)
  end
end
