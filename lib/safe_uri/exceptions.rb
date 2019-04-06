module SafeURI
  class SafeURIERROR < StandardError; end
  class UnsupportedScheme < SafeURIERROR; end
end
