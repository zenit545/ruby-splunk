# Splunk API for Ruby
require 'net/http'
require 'nokogiri'
require 'nori'
require 'uri'

Nori.parser = :nokogiri

module Splunk

class Splunk
  def initialize(splunk_uri,user,password)
    @uri = splunk_uri 
    res = Nokogiri::XML(api_request("#{@uri}/auth/login", 'username' => user, 'password' => password).body)
    @session_key = res.xpath('/response/sessionKey')[0].content
  end
  
  def search(search, *data)
    search = "search #{search}"
    data[0]["search"] = search
    xml = Nori.parse api_request("#{@uri}/search/jobs/export", *data).body
    raise "Search failed: #{xml["response"]["messages"]["msg"]}" if xml.has_key? "response"
    ret = Array.new
    if xml["results"]["result"] 
      xml["results"]["result"].each do |result|
        rres = Hash.new
        result["field"].each do |field|
          if field.has_key? "@k"
            case field["@k"]
            when '_raw'
              rres[:"#{field["@k"]}"] = field["v"].to_s.gsub /<sgh="1">([^<]*)<\/sg>/, '\1'
            when '_si'
              # FIXME do nothing - we don't handle this yet
            else
              case field["@k"]
              when '_time'
                rres[:"#{field["@k"]}"] = Time.parse field["value"]["text"].to_s 
              else
                if field["value"].instance_of? Array
                  rres[:"#{field["@k"]}"] = Array.new unless rres[:"#{field["@k"]}"] 
                  field["value"].each { |value| rres[:"#{field["@k"]}"] << value["text"].to_s }
                else
                  rres[:"#{field["@k"]}"] = field["value"]["text"].to_s
                end
              end
            end
          end
        end
      ret << rres
      end
    end
    ret
  end

  private 
  
  def api_request(uri, *data)
    endpoint = URI.parse(uri)
    http = Net::HTTP.new endpoint.host, endpoint.port
    if endpoint.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    req = Net::HTTP::Post.new(endpoint.path)
    
    if @session_key
      req['Authorization'] = "Splunk #{@session_key}"
    end

    req.set_form_data(*data)
    http.request req
  end
end

end
