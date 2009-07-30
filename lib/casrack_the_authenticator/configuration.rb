require 'uri'
require 'rack'
require 'rack/utils'

module CasrackTheAuthenticator
  
  class Configuration
    
    DEFAULT_LOGIN_URL = "%s/login"
    
    DEFAULT_SERVICE_VALIDATE_URL = "%s/serviceValidate"
    
    def initialize(params)
      parse_params params
    end
    
    def login_url(service)
      append_service @login_url, service
    end
    
    def service_validate_url(service, ticket)
      url = append_service @service_validate_url, service
      url << '&ticket=' << Rack::Utils.escape(ticket)
    end
    
    private
    
    def parse_params(params)
      if params[:cas_server].nil? && params[:cas_login_url].nil?
        raise ArgumentError.new(":cas_server or :cas_login_url MUST be provided")
      end
      @login_url   = params[:cas_login_url]
      @login_url ||= DEFAULT_LOGIN_URL % params[:cas_server]
      validate_is_url 'login URL', @login_url
      
      if params[:cas_server].nil? && params[:cas_service_validate_url].nil?
        raise ArgumentError.new(":cas_server or :cas_service_validate_url MUST be provided")
      end
      @service_validate_url   = params[:cas_service_validate_url]
      @service_validate_url ||= DEFAULT_SERVICE_VALIDATE_URL % params[:cas_server]
      validate_is_url 'service-validate URL', @service_validate_url
    end
    
    IS_NOT_URL_ERROR_MESSAGE = "%s is not a valid URL"
    
    def validate_is_url(name, possibly_a_url)
      url = URI.parse(possibly_a_url) rescue nil
      raise ArgumentError.new(IS_NOT_URL_ERROR_MESSAGE % name) unless url.kind_of?(URI::HTTP)
    end
    
    def append_service(base, service)
      result = base.dup
      result << (result.include?('?') ? '&' : '?')
      result << 'service='
      result << Rack::Utils.escape(service)
    end
    
  end
  
end