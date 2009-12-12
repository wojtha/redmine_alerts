#
# Color module for Ruby
#
# Functions pack, unpack, rgb2hsl, hsl2rgb ported from CMS DRUPAL (PHP)
# http://api.drupal.org/api/drupal/modules--color--color.module/6/source
#
# Ported in 2009-12-01 by Vojtech Kusy <wojtha@gmail.com>
# Released under the GNU GPL v2
#
# GNU GENERAL PUBLIC LICENSE,  Version 2, June 1991
# Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.

module Color

  def self.rgb2hsl(rgb)
    r, g, b = rgb[0], rgb[1], rgb[2]
    min, max = rgb.min, rgb.max
    delta = max - min
    l = (min + max) / 2
    s = 0
    if l > 0 && l < 1 then
      s = delta / (l < 0.5 ? (2.0 * l) : (2 - 2.0 * l))
    end
    h = 0
    if delta > 0
      h += (g - b) / delta if max == r && max != g
      h += (2 + (b - r) / delta) if max == g && max != b
      h += (4 + (r - g) / delta) if max == b && max != r
      h /= 6.0;
    end
    [h, s, l]
  end

  def self.hsl2rgb(hsl)
    h, s, l = hsl[0], hsl[1], hsl[2]
    m2 = (l <= 0.5) ? l * (s + 1) : l + s - l * s
    m1 = l * 2.0 - m2;

    hue2rgb = lambda do |m1x, m2x, hx|
      hx = (hx < 0) ? hx + 1 : ((hx > 1) ? hx - 1 : hx)
      if (hx * 6.0 < 1) then m1x + (m2x - m1x) * hx * 6.0
      elsif (hx * 2.0 < 1) then m2x
      elsif (hx * 3.0 < 2) then m1x + (m2x - m1x) * (0.666666666666666 - hx) * 6.0
      else m1x end
    end

    [ hue2rgb.call(m1, m2, h + 0.333333333333333),
      hue2rgb.call(m1, m2, h),
      hue2rgb.call(m1, m2, h - 0.333333333333333) ]
  end

  # Helper function for _color_hsl2rgb().
  def self.old_hue2rgb(m1, m2, h)
    h = (h < 0) ? h + 1 : ((h > 1) ? h - 1 : h)
    if (h * 6 < 1)
      m1 + (m2 - m1) * h * 6
    elsif (h * 2 < 1)
      m2
    elsif (h * 3 < 2)
      m1 + (m2 - m1) * (0.66666 - h) * 6
    else
      m1
    end
  end

  def self.pretty_hsl(hsl)
    pty_h = hsl[0].*(360.0).round
    pty_h += 360 if pty_h < 0
    pty_s = hsl[1].*(100.0).round
    pty_l = hsl[2].*(100.0).round
    "#{pty_h}° #{pty_s}% #{pty_l}%"
  end

  # Convert a hex color into an RGB triplet
  def self.unpack(hex, normalize = false)
    if hex.length == 4 then
      hex = hex[1] << hex[1] << hex[2] << hex[2] << hex[3] << hex[3]
    end
    hex.sub('#','').scan(/../).collect do |hx|
      r_part = hx.to_i(16) / (normalize ? 255.0 : 1)
    end
  end

  # Convert an RGB triplet to a hex color
  def self.pack(rgb, normalize = false)
    rgb = rgb.collect { |v| p = v * (normalize ? 255.0 : 1); p.round }
    hex = "#%02x%02x%02x" % rgb
    hex.upcase
  end

  def self.simple_test(clr = "#C5003E")
    #RGB: 197 0 62
    #HSL: 341° 100% 39%
    #Hex: #C5003E

    test_hex = clr
    puts "Hex: #{test_hex}"

    test_hex2rgb = Color::unpack(test_hex, true)
    puts "RGB: #{test_hex2rgb.inspect}"

    test_rgb2hsl = Color::rgb2hsl(test_hex2rgb)
    puts "HSL: #{test_rgb2hsl.inspect}"

    test_pretty_hsl = Color::pretty_hsl(test_rgb2hsl)
    puts "HSL pretty: #{test_pretty_hsl}"

    test_hsl2rgb = Color::hsl2rgb(test_rgb2hsl)
    puts "RGB: #{test_hsl2rgb.inspect}"

    test_rgb2hex = Color::pack(test_hsl2rgb, true)
    puts "Hex: #{test_rgb2hex}"

    puts "TEST " << (test_rgb2hex == clr ? "OK" : "FAILED")
  end

end

#Color::simple_test