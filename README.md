# Fluent::Plugin::Cloudwatch Transform

fluent-plugin-cloudwatch-transform is an output plug-in for [Fluentd](http://fluentd.org)

It can transform the alerts from fluent-plugin-cloudwatch to key-value pairs as "event_name" and "value", 
also add more information from the tag you added in fluent-plugin-cloudwatch.

It also used "highwatermark" gem to store status timestamp to state file or redis cache

## Installation

These instructions assume you already have fluentd installed. 
If you don't, please run through [quick start for fluentd] (https://github.com/fluent/fluentd#quick-start)

Now after you have fluentd installed you can follow either of the steps below:



Add this line to your application's Gemfile:

    $ gem 'fluent-plugin-cloudwatch-transform'

Or install it yourself as:

    $ gem install fluent-plugin-cloudwatch-transform
    
    or	

    $ fluent-gem install fluent-plugin-cloudwatch-transform

//for build the gem locally:

    just download or clone this repository

    in the folder of this repository:

    $ gem build fluent-plugin-cloudwatch-transform.gemspec

    $ sudo gem install ./fluent-plugin-cloudwatch-transform-0.0.5.gem
    

## Usage

### fluent configure
require fluent-plugin-cloudwatch for input.
require highwatermark to store timestamp to file or redis
Add the following into your fluentd config.

    <source>
      type cloudwatch
      tag  #tag with prefix alert.cloudwatch.raw
      # followed with region and availability zone, application name, wiki url in sequence  
      # for example: alert.cloudwatch.raw.region1-AZ1.Form & Printing Services (FPS)."http://runbook.wiki.com"
      aws_key_id   #your id 
      aws_sec_key  #your key
      cw_endpoint  #your endpoint
      interval  #frequency to pull data
      namespace #AWS namepace
      metric_name #selected metric name, like: HealthyHostCount 
      dimensions_name #dimensions name
      dimensions_value # dimensions value
    </source>

    <match alert.cloudwatch.raw.**>
     type cloudwatch_transform
     tag  alert.cloudwatch.out
     state_type file #could be <redis/file/memory>
     state_file /path/to/state/file/or/redis/conf  # the file path for store state or the redis configure

    </match>

    <match alert.cloudwatch.out> 
     type stdout
    </match>


Example of redis.conf (if set state_type = 'redis'):

```
# redis configure
host: 127.0.0.1
port: 6379

```


### input example
    {
       "HealthyHostCount": 6
    }


### output examle

    {
        "event_name": "HealthyHostCount",
        "value": "6.0",
        "raw": {
            "HealthyHostCount": 6
        },
        "receive_time_input": "1426189324",
        "application_name": "Form & Printing Services (FPS)",
        "intermediary_source": "region1-AZ1",
        "runbook": "http://runbook.wiki.com"
        "event_type" : "alert.cloudwatch"
        "tag": "alert.cloudwatch.out"
    }

## To DO
need to write the test





