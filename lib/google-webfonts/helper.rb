module Google
  module Webfonts
  
    # Public: Helper module that includes the google_webfonts_link_tag method.
    # This module is automatically included in your Rails view helpers.
    module Helper
      include ActionView::Helpers::TagHelper
      
      # Public: Generates a Google Webfonts link tag
      # 
      # options - The font options. This can be a String, Symbol, or Hash, or
      #           a combination of all three. If you need to specify a font
      #           size, use a Hash, otherwise a String or Symbol will work.
      #
      # Examples
      #
      #   google_webfonts_link_tag "Droid Sans"
      #   # => '<link href="http://fonts.googleapis.com/css?family=Droid+Sans" rel="stylesheet" type="text/css" />'
      # 
      #   google_webfonts_link_tag :droid_sans
      #   # => '<link href="http://fonts.googleapis.com/css?family=Droid+Sans" rel="stylesheet" type="text/css" />'
      # 
      #   google_webfonts_link_tag :droid_sans => [400, 700]
      #   # => '<link href="http://fonts.googleapis.com/css?family=Droid+Sans:400,700" rel="stylesheet" type="text/css" />'
      # 
      #   google_webfonts_link_tag :droid_sans => [400, 700],
      #                            :yanone_kaffeesatz => [300, 400]
      #   # => '<link href="http://fonts.googleapis.com/css?family=Droid+Sans:400,700|Yanone+Kaffeesatz:300,400" rel="stylesheet" type="text/css" />'
      # 
      #   google_webfonts_link_tag "Droid Sans",
      #                            :yanone_kaffeesatz => 400
      #   # => '<link href="http://fonts.googleapis.com/css?family=Droid+Sans|Yanone+Kaffeesatz:400" rel="stylesheet" type="text/css" />'
      #
      #   google_webfonts_link_tag :roboto => %w(400 700 400italic 700italic), 
      #                            :subset => [:latin, :cyrillic]
      #   # => '<link href='http://fonts.googleapis.com/css?family=Roboto:400,700,400italic,700italic&subset=latin,cyrillic' rel='stylesheet' type='text/css'>'
      # 
      # Returns a <link> tag for the Google Webfonts stylesheet.
      # Raises ArgumentError if no options are passed.
      # Raises ArgumentError if an option is not a Symbol, String, or Hash.
      # Raises ArgumentError if a size is not a String or Fixnum.
      def google_webfonts_link_tag(*options)
        raise ArgumentError, "expected at least one font" if options.empty?
        
        fonts = []
        subset = nil
        
        options.each do |option|
          case option.class.name
          when "Symbol", "String"
            # titleize the font name only if option is a Symbol
            font_name = (option.is_a? Symbol) ? option.to_s.titleize : option
            
            # replace any spaces with pluses
            font_name = font_name.gsub(" ", "+")
            
            # include the font
            fonts << font_name
          when "Hash"
            subset ||= if option.has_key? :subset
              "&subset=" << [option.delete(:subset)].flatten.join(',')
            else '' end
            fonts += option.inject([]) do |result, (font, sizes)|
              # ensure sizes is an Array
              sizes = Array(sizes)
              
              sizes.all? do |size|
                unless size.class == Fixnum || size.class == String
                  raise ArgumentError, "expected a Fixnum or String, got a #{size.class}"
                end
              end
              
              font_name = case font.class.name
                when 'Symbol' then font.to_s.gsub(/_/, ' ').titleize.gsub(" ", "+")
                when 'String' then font.gsub(/_/,'+')
              end
              
              result << "#{font_name}:#{sizes.join(",")}"
            end
          else
            raise ArgumentError, "expected a String, Symbol, or a Hash, got a #{option.class}"
          end
        end
        
        # the fonts are separated by pipes
        family = fonts.join("|")

        # generate https links if we are an https site
        request.ssl? ? request_method = "https" : request_method = "http"

        # return the link tag
        tag 'link', {
            :rel  => :stylesheet,
            :type => Mime::CSS,
            :href => "#{request_method}://fonts.googleapis.com/css?family=#{family}#{subset}"
          }
      end
    end
    
  end
end
