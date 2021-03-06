# basic http server
# Author: Nicolas Maitre
# Date: 07.01.2020

require "socket"
require "uri"

class HTTP
    CODES = {
        :switching_protocols => "101 Switching Protocols",
        :ok => 200,
        :not_found => 404,
        :teapot => 418,
        :server_error => 500,
        :user_error => 400
    }
    def listen port # +yield
        tcp_server = TCPServer.new port
        puts "Listening on port #{port}"
        while session = tcp_server.accept
            on_connection(session){
                |err, req, sess|
                yield err, req, sess
            }
        end
    end

    def on_connection session #+yield
        Thread.new{
            request_lines = [];
            while (line = session.gets) && (line != "\r\n") #tmp until body
                request_lines.push line;
            end
            parsed_request = HTTP.parse_request request_lines

            unless parsed_request
                yield "invalid request"
                next
            end

            return_data = (yield(false, parsed_request, session) || {})

            if return_data[:no_following]
                puts "stop here: 'no_following' parameter specified"
                next
            end
            
            begin
                session.puts "HTTP/1.1 #{CODES[(return_data[:http_code] || :ok)]}"
                #headers
                if return_data[:headers] 
                    return_data[:headers].keys.each { |header_key| 
                        session.puts "#{header_key}: #{return_data[:headers][header_key.to_sym]}"
                    }
                end
                #body
                session.puts ""
                session.print return_data[:body].to_s if return_data[:body]
            rescue => error
                puts "request return print failed #{error}"
                next
            end
            unless return_data[:prevent_session_close]
                session.close
            end
        }
    end

    #STATIC METHODS
    def self.parse_request request_lines
        request = request_lines[0]
        return unless request
        request_array = request.split ' '
        headers = HTTP.parse_headers request_lines.slice 1, request_lines.length - 1
        url_object = HTTP.decode_url request_array[1]
        
        {
            :method => request_array[0],
            :protocol => request_array[2],
            :url => url_object,
            :headers => headers,
            :req => request_lines
        }
    end

    def self.parse_headers headers_lines
        headers = {};
        headers_lines.each{ |line|
            components = line.split ':'
            next if components.length < 2
            headers[components[0].strip] = components[1].strip
        }

        headers
    end

    def self.decode_url url
        url_object = URI.parse url
        path = self.decode_path url_object.path
        query = self.decode_query url_object.query

        {
            :string => url,
            :path => path,
            :path_string => url_object.path,
            :query => query,
            :url_object => url_object,
        }
    end

    def self.decode_query query_string
        return {} unless query_string
        query_array = URI.decode_www_form query_string
        query = {}
        query_array.each { |query_entry|
            query[query_entry[0]] = query_entry[1]
        }

        query
    end
    def self.decode_path path_string
        return [] unless path_string
        path_encoded = path_string.split "/"
        if path_encoded[0] == "" #empty path
            path_encoded = path_encoded.slice 1, path_encoded.length - 1 #remove first entry
        end
        path = []
        path_encoded.each { |path_component|
            path.push URI.decode_www_form_component path_component
        }

        path
    end
end
