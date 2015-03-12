# Fluent::Plugin::Cloudwatch Transform

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
Add the following into your fluentd config.

<match alert.cloudwatch.raw.**>
 type cloudwatch_transform
 tag  alert.cloudwatch.out
</match>

<match alert.cloudwatch.out>
 type stdout
</match>


