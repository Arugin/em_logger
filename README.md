# EventMachine Logger

EM::Logger is a simple async wrapper around the ruby logger class. It responds to all the log levels you are familiar with 
from existing loggers (info, debug, warn, etc.). The only difference is that it's instantiated by passing an existing logger in when initializing.

Getting started
---------------
1. Add SimpleCov to your `Gemfile` and `bundle install`:

    ```ruby
    gem 'em_logger'
    ```
    
2. Require it in code and use:    

    ```ruby
    require 'eventmachine'
    require 'logger'
    require 'em_logger'
        
    logger = EM::Logger.new(Logger.new(STDOUT))

    EM.run do
      logger.debug('Wow!')

      EM.stop
    end
    ```
    
3. How does it work?

It pushes all your log requests into queue and the separate thread pops them and delegates to the standard Ruby logger.

## Copyright

Copyright (c) Valery Mayatsky. See LICENSE for details.
