# ![cubic](https://cloud.githubusercontent.com/assets/613784/13137729/f0ba9ca6-d65d-11e5-9ad7-c3582cc177c3.png) Cubic

Cubic provides a unified interface for performing measurements using different _providers_.

Available providers:

* `Null`: a no-op provider, useful for development and test environments.
* `Memory`: stores all measurements on the primary memory. Useful for ad-hoc tests.
* `Librato`: uses [Librato](https://www.librato.com/) as a metrics provider.

### Installation

~~~ruby
gem "cubic"
~~~

### Interface

All Cubic providers provide the same set of methods for performing measurements:

~~~ruby
Cubic.inc("metric")                             # => for counter-style metrics
Cubic.val("name", 20)                           # => for data series style metrics
Cubic.time("expensive") { expensive_operation } # => for measuring the time for a given operation.
~~~

### The `librato` provider

Usage patterns might differ depending on whether the action being measured is a short, one-off
script or a long-lived running web application.

By default, the Librato provider will synchronise its measurements with the API on every call.
This could be acceptable on a small script, but certainly not ideal in general.

There are two options to synchronise the data in bulks:

~~~ruby
Cubic.transaction do
  Cubic.inc("new_transaction")

  # ...

  if unexpected_errors?
    Cubic.inc("unexpected_error")
  end

  # ...

  Cubic.val("result", result)
end

# only one API call performed at the end of the operation for all measurements within the block.
~~~

The approach above is useful mainly in scenarios where a there is a task to be performed
(a background-processing job, perhaps), and all calls are sent once at the end.

The other approach uses a global queue for measurement calls:

~~~ruby
Cubic.config do |c|
  c.provider = :librato
  c.provider_options = {
    email: "...",
    api_key: "...",
    source: "...",
    queue_size: 20
  }
end
~~~

Using the above, an API call will be sent to synchronise the measurements once  the number of
buffered calls reaches `queue_size`.  Note that the queue is stored in memory and therefore
different processes have different queues.

##### Namespacing

The `librato` provider also supports namespacing, causing a prefix to be applied to a label prior
to synchronisation.

~~~ruby
Cubic.config do |c|
  c.provider = :librato
  c.provider_options = {
    # ...
    namespace: "web_app"
  }
end
~~~

With the above settings, a call to `Cubic.inc("metric")` will be identified as `web_app.metric` on Librato.

##### Metric Names

Note that Librato **does not support metric names with slashes**. If a metric name includes slashes,
the synchronisation with Librato might fail due to this shortcoming. Make sure metric names include
only non-blank characters and dots/underscores.

### Configuration

Cubic can be configured prior to its usage. To generate a default configuration file, run:

~~~console
$ bundle exec cubic init
~~~

On a Rails app, the above will create a `cubic.rb` file on `config/initializers`. On
other environments, it will write its content to the standard output.

*****

Brought to you by [Roomorama](https://www.roomorama.com/).
