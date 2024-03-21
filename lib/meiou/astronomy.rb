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

  def self.zodiac
    [ :cancer,:leo,:capricorn,:gemini,:aquarius,:libra,:taurus,:aries,:pisces ]
  end
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
end

module Meiou
  def self.astronomy
    ASTRO
  end
end
