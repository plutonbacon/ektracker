require 'digest/md5'

module Utils

  def self.compute_md5(filename)
    Digest::MD5.hexdigest(File.read(filename))
  end # def compute_md5

end # module Util
