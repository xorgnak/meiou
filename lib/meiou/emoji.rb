require 'gemoji'

module EMOJI
  
  def self.[] k
    Emoji.find_by_alias(k.to_s)
  end

  def self.translate i
    a = []
    Meiou.extract(i) { |e| if EMOJI[e[:word]]; a << EMOJI[e[:word]].raw; else; a << e[:word]; end }
    return a
  end
end


module Meiou
  def self.simplify i
    EMOJI.translate i
  end
end
