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
        h[e] = TOKI[e]
      end
    end
    return h
  end

  def self.tokipona s
    h = {}
    Tokenizer::WhitespaceTokenizer.new().tokenize(s).each do |e|
      if !/[[:punct:]]/.match(e)
        if TOKI.concept.has_key?(e)
          h[e] = TOKI.concept[e]
        end
      end
    end
    return h
  end
  
  YAML.load(File.read(ENV['TOKIPONA'] || '../tokipona.yaml')).each_pair { |k,v| @@T[k].define(v) }
end
