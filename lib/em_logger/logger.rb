require 'eventmachine'
require 'logger'

module EventMachine
  class LogMessage
    attr_accessor :severity, :message, :progname

    def initialize(severity, message = nil, progname = nil)
      @severity = severity
      @message = message
      @progname = progname
    end

  end

  class Logger

    attr_reader :logger
    attr_reader :logger_queue

    def self.logger(logger = nil)
      @logger ||= new(logger || ::Logger.new(STDOUT))
    end

    def initialize(logger)
      @logger = logger
      @logger_queue = ::Queue.new

      start_worker

      EM.add_shutdown_hook { drain } if EM.reactor_running?
    end

    def add(severity, message = nil, progname = nil)
      return true if severity < @logger.level
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @logger.progname
        end
      end
      @logger_queue.push(LogMessage.new(severity, message, progname))
      @worker.wakeup
    end

    alias log add

    def debug(progname = nil, &block)
      add(::Logger::DEBUG, nil, progname, &block)
    end

    def info(progname = nil, &block)
      add(::Logger::INFO, nil, progname, &block)
    end

    def warn(progname = nil, &block)
      add(::Logger::WARN, nil, progname, &block)
    end

    def error(progname = nil, &block)
      add(::Logger::ERROR, nil, progname, &block)
    end

    def fatal(progname = nil, &block)
      add(::Logger::FATAL, nil, progname, &block)
    end

    def unknown(progname = nil, &block)
      add(::Logger::UNKNOWN, nil, progname, &block)
    end

    def <<(data)
      @logger_queue.push(LogMessage.new(nil, data))
    end

    def method_missing(method, *args, &block)
      return super unless @logger.respond_to?(method)
      @logger.send(method, *args, &block)
    end

    def respond_to?(method, include_private = false)
      @logger.respond_to?(method, include_private) || super(method, include_private)
    end

    private

    def drain
      until @worker.stop?

      end
    end

    def start_worker
      @worker = Thread.new do

        loop do
          until @logger_queue.empty?
            log_message = @logger_queue.pop(true)
            @logger.add(log_message.severity, log_message.message, log_message.progname)
          end
          Thread.stop
        end

      end
      @worker.abort_on_exception = true
    end

  end
end
