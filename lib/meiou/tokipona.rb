require 'tokipona'
require 'yaml'

module TOKI
  @@T = Hash.new { |h,k| h[k] = T.new(k) }
  class T
    attr_reader :pos
    def initialize k
      @id = k
      @pos = {}
    end
    def pos? k
      if @pos.has_key? k
        return true
      else
        return false
      end
    end
    def [] k
      @pos[k]
    end
    def keys
      @pos.keys
    end
    def define h={}
      h.each_pair do |k,v|
        [v].flatten.each { |e| TOKI.concept[e] = @id }
        @pos[k] = v
      end
    end
    def to_h
      @pos
    end
  end
  
  def self.[] k
    @@T[k]
  end
  def self.keys
    @@T.keys
  end

  @@C = {}
  def self.concept
    @@C
  end

  def self.english s
    h = {}
    Tokipona::Tokenizer.tokenize(s).each do |e|
      if !/[[:punct:]]/.match(e)
        h[e] = TOKI[e].to_h
      end
    end
    return h
  end

  def self.tokipona s
    a = []
    Tokenizer::WhitespaceTokenizer.new().tokenize(s).each do |e|
      if !/[[:punct:]]/.match(e)
        if TOKI.concept.has_key?(e)
          a << TOKI.concept[e]
        end
      end
    end
    return %[#{a.join(" ")}.]
  end
  def self.init!
    YAML.load(File.read('lang/tokipona.yaml')).each_pair { |k,v| @@T[k].define(v) }
    return "#{@@T.keys.length} words. #{@@C.keys.length} concepts."
  end
end

module Meiou
  def self.to_toki i
    TOKI.tokipona i
  end
  def self.from_toki i
    TOKI.english i
  end
  @@PHRASE = {}
  def self.on_passphrase k,&b
    @@PHRASE[k] = b
  end
  def self.passphrase? k
    if @@PHRASE.has_key? k
      return true
    else
      return false
    end
  end
  def self.passphrase k, h={}
    @@PHRASE[k].call(h)
  end
end

Meiou.init(:tokipona) { |h| TOKI.init! }
