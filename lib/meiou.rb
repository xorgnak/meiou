# frozen_string_literal: true

require 'pstore'

module Meiou
  TRAMPSTAMP = '[MEIOU]'
  class Error < StandardError; end
  @@COMP = {}
  @@INIT = {}
  @@CONF = {}
  def self.conf
    @@CONF
  end
  def self.compile n, &b
    @@COMP[n] = b
  end
  def self.compile!
    @@COMP.each_pair { |n,b| Meiou.log(n,%[#{b.call(@@CONF[n])}]) }
  end
  def self.init n, &b
    @@INIT[n] = b
  end
  def self.init!
    @@INIT.each_pair { |n,b| Meiou.log(n,%[#{b.call(@@CONF[n])}]) }
  end
  def self.log n, s
    puts %[#{TRAMPSTAMP}[#{n}] #{s}]
  end
end

require_relative "meiou/version"

require_relative "meiou/wiki"

require_relative "meiou/dictionary"

require_relative "meiou/word"

require_relative "meiou/book"

require_relative "meiou/mood"

require_relative "meiou/tokipona"

Meiou.init!
