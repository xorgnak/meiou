require 'tokenizer'

module DICT
  # extract a list of tokens from +payload+ and handle with block passing +index+ and +WORD[word]+.
  def self.[] k
    DICT.know(k, define: true, example: true )
  end
  
  def self.know input, h={}
    a = []
    DICT.keywords(input).each { |e|
      w = WORD[e]
      if h[:define] == true
        if w[:def].length > 0
          a << %[#{w[:word].capitalize} means #{w[:def].sample}.];
        else
          a << %[#{w[:word].capitalize} means #{w[:word]}.];
        end
      end
      BOOK.word(w[:word]) { |r|
        if h[:cite] == true
          a << %[[#{r[:book]}:#{r[:index]}:#{w[:word]}] #{r[:text]}]
        else
          if h[:example] == true
            a << %[#{r[:text]}]
          end
        end
      }
    }
    return a
  end
  
  def self.keywords input, &b
    a = []
    Tokenizer::WhitespaceTokenizer.new().tokenize(input).each do |e|
      d = Meiou.word[e]
      if d != nil
        if "#{e}".length > 2 && !/[[:punct:]]/.match(e) && !['the','and','but','this','that'].include?(e.downcase) && d != false 
          if block_given?
            a << b.call(d)
          else
            a << e
          end
        end
      end
    end
    return a
  end
end

module Meiou
  def self.extract k, &b
    if block_given?
      DICT.keywords(k) { |e| b.call(e) }
    else
      DICT.keywords(k)
    end
  end

  def self.[] k
    DICT.know(k, define: true, example: true)
  end
  def self.define k
    DICT.know(k, define: true)
  end
  def self.example k
    DICT.know(k, example: true)
  end
  def self.cite k
    DICT.know(k, cite: true)
  end
end
