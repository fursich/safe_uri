module SafeURI
  # Kernel.open、URI.open is vulnerable to command injection if pipe charactor '|' is given as input.
  # https://docs.ruby-lang.org/en/2.6.0/Kernel.html#method-c-open
	# https://docs.rubocop.org/en/latest/cops_security/#securityopen
  # This occurs as open-uri delegates its #open method to Kernel#open, while overriding Kernel#open.
  # #open below provides safer alternative to URI.open equivalent.
  # raises exception when pipe charactor is specified (usually Errno::ENOENT)
  def self.open(url, *args, **options)

    parsed_url = parse_url(url)
    if parsed_url.scheme
      if parsed_url.respond_to?(:open)
        parse_url(url).open(*args, **options)
      else
        raise UnsupportedScheme.new, "scheme #{parsed_url.scheme} is not supported by open-uri"
      end
    else
      # avoid falling back to Kernel.open
      File.open(url, *args, **options)
    end
  end

  def self.parse_url(url)
    # To percent-encode multi-byte charactors (that might be included as part of given url)
    # SafeURI relies on Addressable::URI#normalize that can handle proper encoding
    # while avoiding double-encoding when percent-encoded charactors already exists.
    normalized_url = Addressable::URI.parse(url).normalize.to_s
    URI.parse(normalized_url)
  end
end

