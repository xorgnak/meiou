require 'astronomy'

module ASTRO

  @@ASTRO = Astronomy::Information.new

  def self.search k
    h = {}
    @@ASTRO.search(k).each { |e| h[e["name"]] = e["description"] }
    return h
  end

  @@C = Hash.new { |h,k| h[k] = @@ASTRO.topics(k) }

  def self.[] k
    @@C[k]
  end
  
  def self.keys
    @@C.keys
  end

  def self.to_h
    h = Hash.new { |h,k| h[k] = {} }
    ASTRO.keys.each { |e| ASTRO[e].each { |ee| h[e][ee['name']] =  ee["description"] } }
    return h
  end

  def self.to_a
    a = []
    ASTRO.to_h.each_pair { |k,v| v.each_pair { |kk,vv|  a << vv } }
    return a
  end

  def self.to_s
    ASTRO.to_a.join("\n\n")
  end
  
  @@ASTRO.categories.each { |e| @@C[e] }

#  def self.zodiac
#    [ :cancer,:leo,:capricorn,:gemini,:aquarius,:libra,:taurus,:aries,:pisces ]
#  end
  def self.movements
    [ :rising, :falling, 'at rest' ]
  end
  def self.signs
    [ :sun, :moon ]
  end
  def self.orbits
    [ "in retrograde", "in procession", "at equinox", "at perogy", "at apogy" ]
  end
  def self.alignments
    [:parallel,:tangential,:perpendicular]
  end
  def self.planets
    [:mercury,:venus,:mars,:vesta,:ceres,:jupiter,:saturn,:uranus,:neptune,:pluto]
  end
  def self.init!
    File.open("books/astronomy.txt",'w') { |f| f.write(ASTRO.to_s) }
  end
  
end

module ZODIAC
 
  def self.[] k
    d = Meiou.date(k)
    month = d.month
    day = d.day
    
    if month == 12
      if day < 22 
        astro_sign = "Sagittarius"; 
      else
        astro_sign ="capricorn"; 
      end

    elsif month == 1
      if day < 20 
        astro_sign = "Capricorn"; 
      else
        astro_sign = "aquarius"; 
      end
    
    elsif month == 2
      if day < 19 
        astro_sign = "Aquarius"; 
      else
        astro_sign = "pisces"; 
      end
    
    elsif month == 3
      if day < 21
        astro_sign = "Pisces"; 
      else
        astro_sign = "aries"; 
      end
    
    elsif month == 4
      if day < 20 
        astro_sign = "Aries"; 
      else
        astro_sign = "taurus"; 
      end
      
    elsif month == 5
      if day < 21 
        astro_sign = "Taurus"; 
      else
        astro_sign = "gemini"; 
      end
      
    elsif month == 6 
      if day < 21 
        astro_sign = "Gemini"; 
      else
        astro_sign = "cancer"; 
      end
      
    elsif month == 7 
      if day < 23 
        astro_sign = "Cancer"; 
      else
        astro_sign = "leo"; 
      end
      
    elsif month == 8
      if day < 23  
        astro_sign = "Leo"; 
      else
        astro_sign = "virgo"; 
      end
      
    elsif month == 9 
      if day < 23
        astro_sign = "Virgo"; 
      else
        astro_sign = "libra"; 
      end
      
    elsif month == 10
      if day < 23 
        astro_sign = "Libra"; 
      else
        astro_sign = "scorpio";  
      end
      
    elsif month == 11 
      if day < 22 
        astro_sign = "scorpio"; 
      else
        astro_sign = "sagittarius"; 
      end
    end
    return astro_sign
  end
  
end

module Meiou
  def self.astronomy
    ASTRO
  end

  @@Z = Hash.new { |h,k| h[k] = ZODIAC[k] }

  def self.zodiac
    @@Z
  end

  def self.date k
    m = /(?<date>(?<year>\d+)\/(?<month>\d+)\/(?<day>\d+))(?<time> (?<hour>\d+):(?<minute>\d+))?/.match(k)
    DateTime.new(m[:year].to_i,m[:month].to_i,m[:day].to_i,m[:hour].to_i || 0,m[:minute].to_i || 0,0).to_time
  end
end

Meiou.init(:astro) { |h| ASTRO.init! }
