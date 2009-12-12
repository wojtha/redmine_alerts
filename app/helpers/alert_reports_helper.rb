require 'color'

module AlertReportsHelper

  class << self
    def text_color(hex)
      "#" << hex
    end

    def border_color(hex)
      "#" << hex
    end

    def bg_color(hex_clr)
      rgb_change_lightness(hex_clr, 0.95)
    end

    def custom_color(hex_clr, l)
      rgb_change_lightness(hex_clr, l)
    end

    def rgb_change_lightness(hex_clr, l)
      rgb = Color::unpack(hex_clr, true)
      hsl = Color::rgb2hsl(rgb)
      hsl[2] = l
      rgb = Color::hsl2rgb(hsl)
      clr = Color::pack(rgb, true)
      clr
    end
  end

end
