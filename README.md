# Fluent::Plugin::Cloudwatch Transform
stCount",
    "value": "6.0",
    "raw": {
        "HealthyHostCount": 6
    },
    "receive_time_input": "1426189324",
    "application_name": "Form & Printing Services (FPS)",
    "intermediary_source": "cloudwatch",
    "tag": "alert.cloudwatch.out"
}

fluent-plugin-cloudwatch-transform is an output plug-in for [Fluentd](http://fluentd.org)

## Installation

These instructions assume you already have fluentd installed. 
If you don't, please run through [quick start for fluentd] (https://github.com/fluent/fluentd#quick-start)

Now after you have fluentd installed you can follow either of the steps below:

Add this line to your application's Gemfile:

    gem 'fluent-plugin-cloudwatch-transform'

Or install it yourself as:

    $ gem install fluent-plugin-cloudwatch-transform

## Usage

### fluent configure
require fluent-plugin-cloudwatch for input.
Add the following into your fluentd config.

    <source>
      type cloudwatch
      tag  #tag with application name, like: alert.cloudwatch.raw.Form & Printing Services (FPS)
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
    </match>

    <match alert.cloudwatch.out> 
     type stdout
    </match>

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
        "intermediary_source": "cloudwatch",
        "tag": "alert.cloudwatch.out"
    }





