require 'tokenizer'

module DICT
  # extract a list of tokens from +payload+ and handle with block passing +index+ and +WORD[word]+.
  def self.[] k
    DICT.extract(k)
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
  
  def self.extract i, &b
    a = []
    Tokenizer::WhitespaceTokenizer.new().tokenize(i).each do |e|
      d = Meiou.word[e]
      if d != nil
        if "#{e}".length > 2 && !/[[:punct:]]/.match(e) && !['the','and','but','this','that'].include?(e.downcase) && d != false
          #puts %[Meiou | #{e} | #{d[:pos].sample} | #{d[:def].sample}] 
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
  def self.keywords k
    DICT.know(k)
  end
  def self.extract k
    DICT[k]
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
