require 'date'
require 'digest'
require 'uri'
require 'json'
require "base64"

require 'bencode'

module Bencview
  # walk through object, firing `block` on each string leaf
  def self.hash_walk obj, &block
    if obj.respond_to? :to_hash
      r = {}
      obj.to_hash.each do |key, value|
        r[key] = hash_walk value, &block  # recursion
      end
      r
    elsif obj.respond_to? :to_ary
      obj.to_ary.map { |a| hash_walk a, &block } # recursion
    elsif obj.kind_of? String
      yield obj
    else
      obj
    end
  end
end

class Bencview::Torrent
  attr_reader :input, :infohash
  def initialize io
    @input = (BEncode::Parser.new io).parse!
    raise 'invalid input' unless @input
    @infohash = sha1
  end

  def any_to_s obj
    obj.kind_of?(Array) ? [obj.size, obj].join("\n ") : obj.to_s
  end

  def num n
    n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  # BitTorrent specific
  def sha1
    return nil unless @input['info'].kind_of?(Hash)
    Digest::SHA1.hexdigest @input['info'].bencode
  end

  # BitTorrent specific
  def magnet name
    return nil unless @infohash
    "magnet:?xt=urn:btih:#{@infohash}" + (name ? "&dn=#{URI.escape name}.torrent" : "")
  end

  # BitTorrent specific
  def bti obj
    return nil unless obj.kind_of?(Hash)

    r = []
    files = []
    obj.each do |key,val|
      key = key.to_s.strip
      case key
      when /^piece/
      # TODO: calc the chunks
      when /\.utf-8$/
      # ignore (rutracker inserts this)
      when 'files'
        bytes = 0
        max = 0
        val.each do |file|
          bytes += file['length']
          max = file['length'] if max < file['length']
        end
        max = (num max).size + 1

        files.push "files: #{val.size}"
        val.each do |file|
          files.push "%#{max}s %s" % [num(file['length']), file['path'].join('/')]
        end
        files.push "files size: #{num bytes}"

      else
        r.push "#{key}: #{any_to_s val}"
      end
    end

    r.concat files if files
  end

  def to_s
    r = []
    info = nil

    if @infohash
      r.push "infohash: #{@infohash}"
      r.push "uri: #{magnet @input.dig 'info', 'name'}"
    end

    @input.each do |key,val|
      key = key.to_s.strip
      if key == 'info'
        info = bti val
      elsif key =~ /date/
        r.push "#{key}: #{DateTime.strptime(val.to_s, '%s').rfc2822}"
      else
        r.push "#{key}: #{any_to_s val}"
      end
    end

    r.concat info if info
    r.join "\n"
  end

  # walk through object, return a hash suitable for JSON.stringify
  def to_json
    Bencview.hash_walk(@input) do |str|
      begin
        str.to_json
      rescue
        next Base64.strict_encode64 str
      end
      str
    end.to_json
  end

end
