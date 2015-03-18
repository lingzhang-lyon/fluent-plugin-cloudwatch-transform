module Fluent
  class NewrelicOutput < Output
    # First, register the plugin. NAME is the name of this plugin
    # and identifies the plugin in the configuration file.
    Fluent::Plugin.register_output('cloudwatch_transform', self)
    
    #config_param :tag, :string, default:'alert.cloudwatch.out' 
    config_param :tag, :string

    # This method is called before starting.
    def configure(conf)
      super
    end

    # This method is called when starting.
    def start
      super
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
      tag_parts = tag.split('.')
      last_tag = tag_parts[tag_parts.size-1]
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
        newhash['receive_time_input']=timestamp.to_s
        newhash["application_name"] = last_tag
        newhash["intermediary_source"] = "cloudwatch"

        #log the transformed message and emit it
        $log.info "Tranformed message  #{newhash}"
    		Fluent::Engine.emit @tag, time.to_i, newhash
      }
    end

  end
end
