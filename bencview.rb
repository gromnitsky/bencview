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
    obj.kind_of?(Array) ? [obj.size, obj].join("\n ").strip : obj.to_s
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
    "magnet:?xt=urn:btih:#{@infohash}" + (name ? "&dn=#{URI.escape name}" : "")
  end

  # BitTorrent specific
  def bti obj, prefix
    return nil unless obj.kind_of?(Hash)

    rkey = -> key { "#{prefix}#{key}" }

    r = []
    obj.each do |key,val|
      key = key.to_s.strip
      if key == 'piece length'
        # ignore
      elsif key == 'pieces' && obj['piece length']
        pieces = val.bytesize / 20
        r.push "#{rkey.call 'pieces'}: #{num pieces} x #{num obj['piece length']}"
      elsif key =~ /\.utf-8$/
        # ignore
      elsif key =~ /^(files|length)$/
        # ignore, but see below `files_add`
      elsif key == 'profiles' && val.kind_of?(Array)
        val.each {|item| r.concat to_a item, "#{prefix}#{key}/" }
      else
        r.push "#{rkey.call key}: #{val}"
      end
    end

    files = []
    files_add = -> arr do
      bytes = 0
      max = 0
      arr.each do |file|
        bytes += file['length']
        max = file['length'] if max < file['length']
      end
      max = (num max).size + 1

      files.push "#{rkey.call 'files'}: #{arr.size}"
      arr.each do |file|
        files.push "%#{max}s %s" % [num(file['length']), file['path'].join('/')]
      end
      files.push "#{rkey.call 'files size'}: #{num bytes}"
    end

    if obj['files']
      files_add.call obj['files']
    elsif obj['length'] && obj['name']
      files_add.call [{'length' => obj['length'], 'path' => [obj['name']]}]
    end

    r.concat files if files
  end

  def to_a obj=nil, prefix=''
    obj = @input unless obj

    r = []
    info = nil

    rkey = -> key { "#{prefix}#{key}" }

    if @infohash && prefix == ''
      r.push "infohash: #{@infohash}"
      r.push "uri: #{magnet @input.dig 'info', 'name'}"
    end

    obj.each do |key,val|
      key = key.to_s.strip
      if key == 'info'
        info = bti val, "#{prefix}info/"
      elsif val.kind_of? Hash
        r.concat to_a val, "#{prefix}#{key}/" # recursion
      elsif key =~ /date/
        r.push "#{rkey.call key}: #{DateTime.strptime(val.to_s, '%s').rfc2822}"
      elsif key =~ /-list$/
        r.push "#{rkey.call key}: #{any_to_s val}"
      else
        r.push "#{rkey.call key}: #{val}"
      end
    end

    r.concat info if info
    r
  end

  def to_s obj=nil, prefix=''
    (to_a obj, prefix).join "\n"
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
