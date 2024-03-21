
module BOOK
  @@IGNORE = 6
  @@TINY = 12
  @@SMALL = 30
  @@MED = 50
  @@LARGE = 120
  def self.size
    [ @@IGNORE, @@TINY, @@SMALL, @@MED, @@LARGE ]
  end
  def self.sizes
    [ :tiny, :info, :short, :med, :long ]
  end
  def self.size? w
    
    if w.length < BOOK.size[0]
      s = :ignore
    elsif w.length > BOOK.size[0] && w.length <= BOOK.size[1]
      s = :tiny
    elsif w.length > BOOK.size[1] && w.length <= BOOK.size[2]
      s = :info
    elsif w.length > BOOK.size[2] && w.length <= BOOK.size[3]
      s = :short
    elsif w.length > BOOK.size[3] && w.length <= BOOK.size[4]
      s = :med
    elsif w.length > BOOK.size[4]
      s = :long
    end
    return s
  end
  @@BOOK = Hash.new { |h,k| h[k] = Book.new(k) }
  class Book
    def initialize k
      @id = k
      @ind = PStore.new("db/book-#{k}.pstore")     # index sizes
      @sec = PStore.new("db/book-sec-#{k}.pstore") # sections
      @top = PStore.new("db/book-top-#{k}.pstore") # topics
      @tag = PStore.new("db/book-tag-#{k}.pstore") # tags
      @mod = PStore.new("db/book-mod-#{k}.pstore") # moods
      @bin = Hash.new { |h,k| h[k] = PStore.new("db/book-#{@id}-#{k}.pstore") } # sorted bins
    end

    def id; @id; end
    
    def load f
      c = File.read(f)
      c.gsub(/\r\n/,"\n").gsub(/\n\n+/,"\n\n").split("\n\n").each_with_index do |e,i|
        x = e.gsub(/\n/," ").gsub(/\s+/," ").strip;
        if !/Project Gutenberg/.match(x)
          if !/^[[[:upper:]]|[[:blank:]]|[[:punct:]]|[[:digit:]]]*$/.match(x)
            s = BOOK.size?(x.split(/\s/))
            Meiou.log "compile load item", "[#{@id}][#{i}] #{s}"
            if s != :ignore
              @bin[s].transaction { |db| db[i] = x }
              @ind.transaction { |db| db[i] = s }
              @mod.transaction { |db| db[i] = MOOD[x] }
              Meiou.extract(x) { |e| @tag.transaction { |db| if !db.key?(e[:word]); db[e[:word]] = []; end; db[e[:word]] << i; } }
            end
          else
            if !/GUTENBERG/.match(x)
              Meiou.log "compile load section", %[#{@id}>#{i}: #{x}]
              @sec.transaction { |db| db[i] = x }
              @top.transaction { |db| db[x] = i }
            end
          end
        end
      end
    end
    
    def [] k
      n = @ind.transaction { |db| db[k] }
      @bin[n].transaction { |db| db[k] }
    end
    def mood k
      @mod.transaction { |db| db[k] }
    end
    def tag k
      @tag.transaction { |db| db[k] }
    end
    def tags
      @tag.transaction { |db| db.keys }
    end
    def topic k
      @top.transaction { |db| db[k] }
    end
    def topics
      h = {}
      @top.transaction { |db| db.keys.each { |e| h[e] = db[e] } }
      return h
    end

    def section k
      @sec.transaction { |db| db[k] }
    end

    def sections
      h = {}
      @sec.transaction { |db| db.keys.each { |e| h[e] = db[e] } }
      return h
    end

    def filter s, k
      a = []
      @bin[s].transaction { |db| db.keys.map { |e| if Regexp.new(k).match(db[e]); a << e end } }
      return a
    end
    def map &b
      BOOK.sizes.each do |size|
        @bin[size].transaction { |db| db.keys.map { |e| b.call(db[e]) } }
      end
    end
    def each k, &b
      @bin[k].transaction { |db| db.keys.map { |e| b.call(db[e]) } }
      return nil
    end
  end

  def self.[] k
    @@BOOK[k]
  end
  
  def self.keys
    @@BOOK.keys
  end

  def self.topic k
    h = {}
    @@BOOK.keys.map { |e| h[e] = @@BOOK[e].topic(k) }
    return h
  end

  def self.topics
    h = {}
    @@BOOK.keys.map { |e| h[e] = @@BOOK[e].topics }
    return h
  end

  def self.section k
    h = {}
    @@BOOK.keys.map { |e| h[e] = @@BOOK[e].section(k) }
    return h
  end
  
  def self.tag k
    h = {}
    @@BOOK.keys.map { |e| h[e] = @@BOOK[e].tag(k) }
    return h
  end
  
  def self.tags
    h = {}
    @@BOOK.keys.map { |e| h[e] = @@BOOK[e].tags }
    return h    
  end
  
  def self.sections
    h = {}
    @@BOOK.keys.map { |e| h[e] = @@BOOK[e].sections }
    return h
  end

  def self.find k, *t, &b
    @@BOOK.keys.map { |kk| [t, :tiny].uniq.flatten.each { |s| book = @@BOOK[kk]; book.filter(s,k).each { |e| b.call({ book: kk, index: e, mood: book.mood(e), text: book[e] }); } } }
    return nil
  end

  # Get +num+ number of "opinions" of +word+ based on compiled +BOOK.tag(word)+ keywords and pass it to block
  def self.word word, *num, &block
    a = []
    BOOK.tag(word).each_pair { |k,v| if v != nil; v.sample(num[0] || 3).compact.uniq.shuffle.each { |e| a << { book: k, index: e, mood: BOOK[k].mood(e), text: BOOK[k][e] } }; end }
    a.flatten.sample(num[1] || num[0] || 3).compact.uniq.shuffle.each { |e| block.call(e) }
    return nil
  end

  def self.to_a
    a = []
    @@BOOK.each_pair { |k,v| v.map { |e| a << e }}
    return a.compact
  end

  def self.to_s
    BOOK.to_a.join("\n\n")
  end

  def self.init!
    Dir['books/*'].each { |e|
      k = e.gsub("books/", "").gsub(".txt", "").gsub("_", " ");
      Meiou.log :init_scan, %[Scanning #{k}...]
      @@BOOK[k]
    }
    Meiou.log :init_done, %[Books scanned!]
    return "DONE!"    
  end
  
  def self.compile!
    Dir['books/*'].each { |e|
      k = e.gsub("books/", "").gsub(".txt", "").gsub("_", " ");
      Meiou.log :compile_load, %[#{k}...]
      @@BOOK[k].load(e)
    }
    Meiou.log :compile_done, %[done!]
    return "DONE!"
  end
 
end

Meiou.compile(:book) { |h| BOOK.compile! }
Meiou.init(:book) { |h| BOOK.init! }
