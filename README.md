# fluent-plugin-gelf

[![CircleCI](https://circleci.com/gh/FundingCircle/fluent-plugin-gelf/tree/master.svg?style=svg&circle-token=d781ef54862db51be146a2a2ad7aa9d783bb177a)](https://circleci.com/gh/FundingCircle/fluent-plugin-gelf/tree/master)

A [fluentd](https://www.fluentd.org/) output plugin for sending log events to
[Graylog](https://docs.graylog.org/).

## Installation

### RubyGems

```
$ gem install fluent-plugin-gelf
```

### Bundler

Add this line to your application's Gemfile:

```ruby
gem "fluent-plugin-gelf"
```

And then execute:

```
$ bundle
```

## Usage

This `gelf` plugin is for fluentd v1.0 or later.

```
<match app.**>
  output_data_type gelf
</match>
```

## Configuration

#### host (string) (required)

The hostname of your Graylog cluster.

####o port (integer) (optional)

The TCP port of your Graylog cluster. Default value: `12201`.

## Releases

The CircleCI build for this project manages gem releases to RubyGems. To release
a new version of this gem, create a tag for the version and push it. It will
then be built and deployed automatically.

## Copyright and License

Copyright © 2017 Funding Circle Ltd.

Licensed under the [BSD 3-Clause License](LICENSE).
