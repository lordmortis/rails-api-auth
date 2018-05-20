require 'strscan'

module ActsAsApiAuthable::Util
  class AuthorizationHeader
    attr_reader :type, :params

    def initialize(value)
      unless value.is_a? String
        @type = :unknown
        return
      end

      scanner = StringScanner.new(value.strip)

      @type = find_type(scanner)
      @params = parse_params(scanner)
    end

    def keys
      @params.keys
    end

    def params
      keys
    end

    def [](key)
      @params[key]
    end

    def has_key?(value)
      has_param?(value)
    end

    def has_param?(value)
      @params.has_key?(value)
    end

    private

    ANYTHING_BUT_EQ = /[^\s\=]+/
    EQ = /=/
    EITHERQUOTE = /['"]/
    ENDINGSINGLEQUOTE = /(?<!\\)'/
    ENDINGDOUBLEQUOTE = /(?<!\\)"/
    WHITESPACE_ANDOR_QUOTE = /[\s,]+/
    UNESCAPED_TOKEN = /[^,\s]+/
    NON_WHITESPACE = /[^\s]+/

    def find_type(scanner)
      unless scanner.check(NON_WHITESPACE) == scanner.check(ANYTHING_BUT_EQ)
        return nil
      end

      type = scanner.scan(NON_WHITESPACE)
      scanner.scan(WHITESPACE_ANDOR_QUOTE)
      return nil if type.nil?
      type.downcase.to_sym
    end

    def parse_params(scanner)
      params = {}
      until scanner.eos? do
        key = scanner.scan(ANYTHING_BUT_EQ).downcase.to_sym
        if scanner.skip(EQ)
          if scanner.eos?
            params[key] = ''
            return params
          end
          quote = scanner.scan(EITHERQUOTE)
          unless quote.nil?
            if quote == "'"
              params[key] = scanner.scan_until(ENDINGSINGLEQUOTE)[0..-2]
              params[key].gsub!("\\'", "'")
            else
              params[key] = scanner.scan_until(ENDINGDOUBLEQUOTE)[0..-2]
              params[key].gsub!("\\\"", "\"")
            end
          else
            params[key] = scanner.scan(UNESCAPED_TOKEN)
          end
        end
        scanner.skip(WHITESPACE_ANDOR_QUOTE)
      end

      params
    end
  end
end