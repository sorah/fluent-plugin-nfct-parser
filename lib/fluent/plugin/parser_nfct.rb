require 'fluent-plugin-nfct-parser/version'
require 'fluent/plugin/parser_none'
require 'strptime'

module Fluent
  module Plugin
    class NfctParser < Parser
       Fluent::Plugin.register_parser("nfct", self)

       desc "Parse 'extended' format which includes L3 information"
       config_param :extended, :bool, default: false
       desc "Parse 'ktimestamp' format"
       config_param :ktimestamp, :bool, default: false


       regexp_base = proc { |ext|
         /
           ^
           \s*
           \[(?<msg_type>.+?)\]\s+
           #{ext[:l3protocol]}
           (?<protocol>.+?)\s+(?<protonum>\d+)\s+
           (?:(?<timeout>\d+)\s+)?
           (?:(?<state>[A-Z].+?)\s+)?
           (?<remaining>.*)
           $
         /x
       }
       REGEXP = regexp_base[{}]
       REGEXP_EXTENDED = regexp_base[
         l3protocol: '(?<l3protocol>.+?)\s+(?<l3protonum>\d+)\s+',
       ]

       TIME_REGEXP = /\A\[.+=/
       NUM_REGEXP = /\A\d+\z/
       DELIMITER = /\s+/
       LABEL_SCAN = /(\[.+?\]|.+?)(?:\s|\z)/

       def configure(conf)
         super
         @regexp = @extended ? REGEXP_EXTENDED : REGEXP
         if @ktimestamp
           @time_parser = Strptime.new('%b %d %H:%M:%S %Y')
         end
       end

       def parse(text)
         m = text.match(@regexp)
         unless m
           yield nil, nil
           return
         end

         r = m.named_captures
         %w(protonum l3protonum timeout).each do |k|
           r[k] = r[k].to_i if r[k]
         end

         if @ktimestamp
           parts = r.delete('remaining')&.scan(LABEL_SCAN).flatten || []
         else
           parts = r.delete('remaining')&.split(DELIMITER) || []
         end
         parts.each do |part|
           case
           when @ktimestamp && part.match?(TIME_REGEXP)
             k,v = part[1..-2].split(?=,2)
             begin
               r[k] = @time_parser.execi(v[4..-1])
             rescue ArgumentError
             end
           when part[0] == '['
             r[part[1..-2].downcase] = true
           else
             k,v = part.split(?=, 2)
             if v.match(NUM_REGEXP)
               r[k] = v.to_i
             else
               r[k] = v
             end
           end
         end
         yield convert_values(parse_time(r), r)
       end
    end
  end
end
