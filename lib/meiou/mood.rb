require 'textmood'

module MOOD
  @@MOOD = PStore.new("db/moods.pstore")
  def self.[] k
    @@MOOD.transaction { |db| db[k] }
  end
  def self.keys
    @@MOOD.transaction { |db| db.keys }
  end
  def self.incr k, n
    @@MOOD.transaction { |db| x = db[k].to_f; db[k] = x + n[0] || 1 }
  end
  def self.decr k, *n
    @@MOOD.transaction { |db| x = db[k].to_f; db[k] = x + n[0] || 1 }
  end
  def self.update k, s
    MOOD.incr(k, MOOD[s])
  end
  def self.[] p
    TextMood.new(language: "en", ternary_output: true, start_ngram: 1, end_ngram: 4).analyze(p).to_f
  end
end

module Meiou
  def self.mood
    MOOD
  end
end
