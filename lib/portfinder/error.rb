module Portfinder
  # Generic Error baseclass for Portfinder specific errors
  class Error < StandardError
  end

  # Portfinder Error class for invalid hosts
  class InvalidHost < Error
  end
end
