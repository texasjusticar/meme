  require 'net/http'
  require 'rubygems'
  require 'nokogiri'
  require 'cgi'
  require 'meme/version'
  require 'meme/generators'

  ##
  # Generate memes using http://memegenerator.net

module Meme
  class Generator

    ##
    # Sometimes your meme will have an error, fix it!

    class Error < RuntimeError; end

    ##
    # For statistics!

    USER_AGENT = "meme/#{::Meme::VERSION} Ruby/#{RUBY_VERSION}"

    ##
    # Looks up generator name

    def parse(name, attributes)
      [attributes[:imageID], name, attributes[:generatorID], attributes[:default]]
    end

    ##
    # Interface for the executable

    def self.run argv = ARGV
      generator = ARGV.shift

      if generator == '--list' then
        width = Meme::GENERATORS.keys.map { |command| command.length }.max

        Meme::GENERATORS.sort.each do |command, (id, name, _)|
          puts "%-*s  %s" % [width, command, name]
        end

        exit
      end

      text_only = if generator == '--text'
        generator = ARGV.shift
        true
      else
        false
      end

      abort "#{$0} [GENERATOR|--list] LINE [ADDITONAL_LINES]" if ARGV.empty?

      meme = new generator
      link = meme.generate(*ARGV)

      if $stdout.tty? || text_only
        puts link
      else
        puts meme.fetch link
      end

    rescue Interrupt
      exit
    rescue SystemExit
      raise
    rescue Exception => e
      puts e.backtrace.join "\n\t" if $DEBUG
      abort "ERROR: #{e.message} (#{e.class})"
    end

    ##
    # Generates links for +generator+

    def initialize generator
      @template_id, @generator_name, @generator_id, @default_line = parse(generator, Meme::GENERATORS[generator])
    end

    ##
    # Generates a meme with +line1+ and +line2+.  For some generators you only
    # have to supply one line because the first line is defaulted for you.
    # Isn't that great?

    def generate *args
      url = URI.parse 'http://memegenerator.net/create/instance'
      res = nil
      location = nil

      # Prepend the default line if this meme has one and we only had 1 text input
      args.unshift @default_line if @default_line and args.size <= 1

      raise Error, "two lines are required for #{@generator_name}" unless
        args.size > 1

      post_data = { 'imageID'    => @template_id,
                    'generatorID' => @generator_id,
                    'watermark1' => 1,
                    'uploadtoImgur' => 'false' }

      # go through each argument and add it back into the post data as textN
      (0..args.size).map {|num| post_data.merge! "text#{num}" => args[num] }

      Net::HTTP.start url.host do |http|
        post = Net::HTTP::Post.new url.path
        post['User-Agent'] = USER_AGENT
        post.set_form_data post_data

        res = http.request post
        location = res['Location']
        redirect = url + location

        get = Net::HTTP::Get.new redirect.request_uri
        get['User-Agent'] = USER_AGENT

        res = http.request get
      end

      if Net::HTTPSuccess === res then
        doc = Nokogiri.HTML res.body
        doc.css("meta")[7]['content']
      else
        raise Error, "memegenerator.net appears to be down, got #{res.code}"
      end
    end

    def fetch link
      url = URI.parse link
      res = nil

      Net::HTTP.start url.host do |http|
        get = Net::HTTP::Get.new url.request_uri
        get['User-Agent'] = USER_AGENT

        res = http.request get
      end
      res.body
    end

  end
end
