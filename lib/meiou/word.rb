require 'rwordnet'

module WORD
  @@WORD = Hash.new { |h,k| if !h.has_key?(k); w = WORD.term(k); if w != false; h[k] = w; end; end }
  # find +word+.
  def self.term word
    ds, df = [], []
    WordNet::Lemma.find_all(word).each { |e| ds << e.pos; e.synsets.each  { |ee| df << ee.gloss.gsub('"', "").gsub("--", " ").split("; ")[0] } }
    #if ds.include?('n') && !ds.include?('v')                                                                                                                                                                                    
    if ds.length > 0
      return  { word: word, pos: ds, def: df }
    else
      return false
    end
  end
  
  # +word+
  def self.[] word
    @@WORD[word]
  end

  # +words+
  def self.keys
    @@WORD.keys
  end
end

module Meiou
  def self.word
    WORD
  end
  def self.words
    WORD.keys
  end
end
