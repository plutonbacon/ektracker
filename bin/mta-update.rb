#!/usr/bin/env ruby

# Check http://malware-traffic-analysis.net for new pcaps and/or artifacts
# related to tracked exploit kits.

require 'rubygems'
require 'bundler/setup'

require 'archive/zip'
require 'filemagic'
require 'http'
require 'nokogiri'
require 'simple-rss'

require_relative '../lib/ektracker/app'

title_keywords = ['angler', 'nuclear', 'rig', 'neutrino']

# Clear out and recreate staging
FileUtils.rm_rf("artifacts/staging")
FileUtils.mkdir_p("artifacts/staging")

response = HTTP.headers(:user_agent => USER_AGENT)
               .get('http://malware-traffic-analysis.net/blog-entries.rss')
rss = SimpleRSS.parse(response)
rss.items.each do |item|
  # Cheap, dead simple rate limiting
  sleep(rand(1..10))

  # Grab and parse the post if it contains relevant keywords
  title = item.title.downcase!
  matches = []
  title_keywords.each do |keyword| 
    matches.push(keyword) if title.include?(keyword)
  end
  
  source_link_id = Zlib::crc32(item.link)
  root_link = item.link.gsub(/index.html/, '')

  if matches.size > 0
    response = HTTP.headers(:user_agent => USER_AGENT)
                   .get(item.link)
    doc = Nokogiri::HTML.parse(response.body.to_s)
    links = doc.css('a')
    links.each do |link|
      href = link['href']
      if href.include?('.zip')
        artifact_link = root_link + href 
        response = HTTP.headers(:user_agent => USER_AGENT)
                       .get(artifact_link)
        open("artifacts/staging/#{href}", "wb") do |file|
          file.write(response.body)
          puts "Writing #{href} ..."
        end
        FileUtils.mkdir_p "artifacts/#{source_link_id}"
        Archive::Zip.extract("artifacts/staging/#{href}", "artifacts/#{source_link_id}", :password => 'infected')

        Dir["artifacts/#{source_link_id}/20*"].each do |file|
          md5 = Utils::compute_md5(file)
          FileUtils.rm_rf("artifacts/#{source_link_id}/#{md5}")
          FileUtils.mv(file, "artifacts/#{source_link_id}/#{md5}")
          FileUtils.rm_rf(file)

          artifact = Artifact.new(:ek_type => matches[0],
                                  :mime => FileMagic.new(FileMagic::MAGIC_MIME).file("artifacts/#{source_link_id}/#{md5}"),
                                  :source => 'mta',
                                  :source_link => item.link,
                                  :fs_path => "artifacts/#{source_link_id}/#{md5}",
                                  :md5 => md5,
                                  :size => 0)
          artifact.save
        end
      end
    end
  end
end
