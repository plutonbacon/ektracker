class Artifact < Sequel::Model

  plugin :validation_helpers

  def validate
    super
    validates_presence [:ek_type, :mime, :source, :source_link, 
                        :fs_path, :md5, :mime]
  end # def validate

  def before_create
    super
    self.created_at = Time.now
    self.updated_at = Time.now
  end # def before_create

end # class Artifact
