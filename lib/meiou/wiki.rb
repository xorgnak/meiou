require 'wikipedia-client'

module WIKIPEDIA
  @@INFO = Hash.new do |h,k|
    if x = Wikipedia.find(k.to_s).summary
      h[k] = x.gsub(/\n+/,"\n").split("\n")
    else
      h[k] = false
    end
  end
  def self.[] k
    @@INFO[k]
  end
  def self.keys
    @@INFO.keys
  end
  def self.to_h
    @@INFO
  end
end

module WIKI
  
  @@GPS = Hash.new { |h,k| h[k] = Gps.new(k) }
  class Gps
    def initialize k
      @id = k
      @x = PStore.new("db/gps-#{k}.pstore")
    end
    def [] k
      @x.transaction { |db| db[k] }
    end
    def []= k,v
      @x.transaction { |db| db[k] = v }
    end
    def id; @id; end
  end
  
  def self.gps
    @@GPS
  end

  @@W = Hash.new { |h,k| h[k] = W.new(k) }
  class W
    def initialize k
      @id = k
      @x = PStore.new("db/w-#{k}.pstore")
    end
    def [] k
      @x.transaction { |db| db[k] }
    end
    def []= k,v
      @x.transaction { |db| db[k] = v }
    end
    def id; @id; end
    
  end

  
  @@WIKI = Hash.new do |h,k|
    a, x = [], @@W[k.to_s]
    if x[:text] == nil
      s = Wikipedia.find(k.to_s)
      if s != nil
        %[#{s.summary}].split("\n").each { |e|
          if !/^=+/.match(e)
            a << %[#{e}]
          end
        }
        aa = []; a.join("\n").split(/\n+/).each { |e| aa << e.gsub('"',"'").gsub(/\s+/," ").strip }
        x[:text] = aa.join("\n\n")
        x[:url] = s.fullurl
        x[:edit] = s.editurl
        cc, c = [], [];
        [s.categories].flatten.each { |e| if e != nil; cc << e.gsub("Category:",""); end }
        cc.each { |e|
          if !/^All articles/.match(e) && !/^Articles/.match(e) && !/^Coordinates on/.match(e) && !/^Short description is/.match(e)
            c << e
          end
        }
        x[:categories] = c.join("\n\n")
        
        x[:google] = "https://www.google.com/search?q=#{k.gsub(" ","+")}"
        
        x[:map] = "https://www.google.com/maps/place/#{k.gsub(" ","+")}"
        
        xx = s.coordinates
        
        if xx != nil
          x[:lat] = xx[0]
          x[:lon] = xx[1]
          g = @@GPS[k.to_s]
          g[:lat] = xx[0]
          g[:lon] = xx[1]
          g[:map] = x[:map]
          g[:google] = x[:google]
          g[:edit] = x[:edit]
          g[:url] = x[:url]
          g[:text] = x[:text]          
        end
      end
      h[k] = x
    end
  end 
  def self.[] k
    @@WIKI[k]
  end
  def self.keys
    @@WIKI.keys
  end
  def self.to_h
    @@WIKI
  end
end
