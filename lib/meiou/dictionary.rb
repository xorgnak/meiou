require 'tokenizer'

module DICT
  # extract a list of tokens from +payload+ and handle with block passing +index+ and +WORD[word]+.
  def self.[] payload, &block
    Tokenizer::WhitespaceTokenizer.new().tokenize(payload).each do |e|
      d = Meiou.word[e]
      if d != nil
        if "#{e}".length > 2 && !/[[:punct:]]/.match(e) && !['the','and','but','this','that'].include?(e.downcase) && d != false
          #puts %[Meiou | #{e} | #{d[:pos].sample} | #{d[:def].sample}]
          block.call(d)
        end
      end
    end
    return nil
  end

  def self.know input, h={}
    a = []   
    DICT[input] { |w|
      if h[:define] == true
        a << %[#{w[:word].capitalize} means #{w[:def].sample}.];
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
end

module Meiou
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
