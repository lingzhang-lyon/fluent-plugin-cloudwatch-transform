module Fluent
  class CloudWatchTransOutput < Output
    # First, register the plugin. NAME is the name of this plugin
    # and identifies the plugin in the configuration file.
    Fluent::Plugin.register_output('cloudwatch_transform', self)
    
    config_param  :out_tag,           :string
    config_param  :state_type,    :string,  :default => nil
    config_param  :state_file,    :string,  :default => nil
    config_param  :state_tag,     :string,  :default => nil

    # This method is called before starting.
    def configure(conf)
      super
    end

    def initialize
      require 'highwatermark'
      super
    end # def initialize

    # This method is called when starting.
    def start
      super
      @highwatermark = Highwatermark::HighWaterMark.new(@state_file, @state_type)

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
      #tag_parts = tag.split('.')
      tag_parts = tag.scan( /([^".]+)|"([^"]+)"/ ).flatten.compact
      # the prefix of tag should be like alert.cloudwatch.raw.***
      # so start from tag_parts[3]
      regionAZ = tag_parts[3]
      application_name = tag_parts[4]
      runbook_url = tag_parts[5]
      chain.next
      es.each {|time,record|

    		newhash = Hash.new
    		# though there is just one key-value pair in cloudwatch alert record, we use a loop to add context for it.
    		record.each_pair do |singlekey, singlevalue|
    				newhash["event_name"] = singlekey
            newhash["value"] = singlevalue.to_s
            newhash["raw"] ={singlekey => singlevalue}
        end
        # add more information for the cloudwatch alert
        timestamp = Engine.now # Should be receive_time_input
        newhash["receive_time_input"]=timestamp.to_s
        newhash["application_name"] = application_name
        newhash["intermediary_source"] = regionAZ
        newhash["runbook"] =  runbook_url
        newhash["event_type"] = "alert.cloudwatch"

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
