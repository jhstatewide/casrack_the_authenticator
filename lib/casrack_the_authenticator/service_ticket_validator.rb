require 'nokogiri'

module CasrackTheAuthenticator
  
  class ServiceTicketValidator
    
    VALIDATION_REQUEST_HEADERS = { 'Accept' => '*/*' }
    
    # Build a validator from a +configuration+, a
    # +return_to+ URL, and a +ticket+.
    def initialize(configuration, return_to_url, ticket)
      @uri = URI.parse(configuration.service_validate_url(return_to_url, ticket))
    end
    
    # Request validation of the ticket from the CAS server's
    # serviceValidate (CAS 2.0) function.
    #
    # Returns a username if the response is valid; +nil+ otherwise.
    #
    # Raises any connection errors encountered.
    #
    # Swallows all XML parsing errors (and returns +nil+ in those cases).
    def user
      parse_user(get_validation_response_body)
    end
    
    private
    
    def get_validation_response_body
      result = ''
      Net::HTTP.new(@uri.host, @uri.port).start do |c|
        response = c.get "#{@uri.path}?#{@uri.query}", VALIDATION_REQUEST_HEADERS
        result = response.body
      end
      result
    end
    
    def parse_user(body)
      begin
        doc = Nokogiri::XML(body)
        node = doc.xpath('/serviceResponse/authenticationSuccess/user').first
        node.nil? ? nil : node.content
      rescue Nokogiri::XML::XPath::SyntaxError
        nil
      end
    end
    
  end
  
end