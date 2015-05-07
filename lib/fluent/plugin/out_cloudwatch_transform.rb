module Fluent
  class CloudWatchTransOutput < Output
    # First, register the plugin. NAME is the name of this plugin
    # and identifies the plugin in the configuration file.
    Fluent::Plugin.register_output('cloudwatch_transform', self)
    
    config_param  :out_tag,           :string
    config_param  :state_tag,     :string,  :default => "spectrum"
    config_param  :state_type,    :string,  :default => "memory"
    config_param  :state_file,    :string,  :default => nil
    config_param  :redis_host,    :string,  :default => nil
    config_param  :redis_port,    :string,  :default => nil
    config_param  :name_for_origin_key,     :string,  :default => nil
    config_param  :name_for_origin_value,     :string,  :default => nil

    #also need add config for info_name and postion_in_tag (start from 0) within <tag_infos> </tag_infos> block

    # This method is called before starting.
    def configure(conf)
      super
      # Read configuration for tag_infos and create a hash
      @tag_infos = Hash.new
      conf.elements.select { |element| element.name == 'tag_infos' }.each { |element|
        element.each_pair { |info_name, position_in_tag|
          @tag_infos[info_name] = position_in_tag.to_i
          $log.info "Added tag_infos: #{info_name}=>#{@tag_infos[info_name]}"
        }
      }

      # configure for highwatermark
      @highwatermark_parameters={
        "state_tag" => @state_tag,     
        "state_type" => @state_type,
        "state_file" => @state_file,
        "redis_host" => @redis_host,
        "redis_port" => @redis_port      
      }
      $log.info "highwatermark_parameters: #{@highwatermark_parameters}"

    end

    def initialize
      require 'highwatermark'
      super
    end # def initialize

    # This method is called when starting.
    def start
      super
      @highwatermark = Highwatermark::HighWaterMark.new(@highwatermark_parameters)

    end

    # This method is called when shutting down.
    def shutdown
      super
    end

    # This method is called when an event reaches Fluentd.
    # 'es' is a Fluent::EventStream object that includes multiple events.
    # You can use 'es.each {|time,record| ... }' to retrieve events.
    # 'chain' is an object that manages transactions. Call 'chain.next' at
    # appropriate points and rollback if it raises an exception.
    #
    # NOTE! This method is called by Fluentd's main thread so you should not write slow routine here. It causes Fluentd's performance degression.
    def emit(tag, es, chain)
      tag_parts = tag.scan( /([^".]+)|"([^"]+)"/ ).flatten.compact
      # split the tags with .
      # ingnore the . within ""

      chain.next
      es.each {|time,record|

    		newhash = Hash.new
    		# though there is just one key-value pair in cloudwatch alert record, we use a loop to add context for it.
    		record.each_pair do |singlekey, singlevalue|
    				newhash[@name_for_origin_key] = singlekey
            newhash[@name_for_origin_value] = singlevalue.to_s
            newhash["raw"] ={singlekey => singlevalue}
        end
        # add more information for the cloudwatch alert
        # fixed info
        timestamp = Engine.now # Should be receive_time_input
        newhash["receive_time_input"]=timestamp.to_s
        newhash["event_type"] = @out_tag

        @tag_infos.each do |info_name, position_in_tag|
          newhash[info_name] = tag_parts[position_in_tag]
        end

          

        if @highwatermark.last_records(@state_tag)
          last_hwm = @highwatermark.last_records(@state_tag)
          $log.info "got hwm form state file: #{last_hwm.to_i}"
        else
          $log.info "no hwm yet"
        end

        @highwatermark.update_records(timestamp.to_s,@state_tag)

        #log the transformed message and emit it
        $log.info "Tranformed message  #{newhash}"
    		Fluent::Engine.emit @out_tag, time.to_i, newhash
      }
    end

  end
end
