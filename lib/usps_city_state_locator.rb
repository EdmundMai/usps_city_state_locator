require "usps_city_state_locator/version"

module UspsCityStateLocator
  class UspsCityStateLocator
    attr_accessor :zip_code

    def initialize(args ={})
      @zip_code = args[:zip_code]
    end

    def make_request
      uri = URI.parse(USPS_API['api_url'])
      params = { 'XML' => xml_for_request, 'API' => 'CityStateLookup' }
      uri.query = URI.encode_www_form(params)
      begin
        # return Net::HTTP.get(uri)
        response = Net::HTTP.get(uri)
        xml = Nokogiri::XML(response)
        return {'city' => xml.xpath("//CityStateLookupResponse//ZipCode//City").first.try(:content), 
                'state' => xml.xpath("//CityStateLookupResponse//ZipCode//State").first.try(:content),
                'zip_code' => zip_code }
      rescue => error
        Rails.logger.info "UPS Error => #{error}"
        return ""
      end
    end

    def xml_for_request
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.CityStateLookupRequest('USERID' => USPS_API["user_id"]) {
          xml.ZipCode('ID' => '0') {
            xml.Zip5 zip_code
          }
        }
      end
      return builder.to_xml
    end

  end
end
