require 'spec_helper'

describe EventMachine::Logger do
  let(:logger) { ::Logger.new(STDOUT) }

  describe 'creating' do
    subject { EventMachine::Logger.new(logger, batch_size: 1) }

    it 'instantiates with a logger' do
      EM.run_block do
        expect(subject.logger).to eq(logger)
      end
    end

    it 'adds a shutdown hook when the reactor is running' do
      EM.run_block do
        expect(EM).to receive(:add_shutdown_hook).and_yield
        subject
      end
    end

    it 'starts the queue worker' do
      expect(logger).to receive('add').once

      EM.run_block do
        subject.debug('this is a test')
        EM.stop
      end
    end
  end

  describe 'log statements' do
    let(:em_logger) { EventMachine::Logger.new(logger, batch_size: 1) }

    %w(debug info warn error fatal).each do |l|
      describe "##{l}" do
        it 'pushes the log message onto the logger_queue' do
          expect(em_logger.logger_queue).to receive('push').once
          em_logger.send("#{l}", 'this is a test')
        end
      end
    end

    describe '#unknown' do
      it 'pushes the log message onto the logger_queue' do
        expect(em_logger.logger_queue).to receive('push').once
        em_logger.unknown('this is a test')
      end
    end

    describe '#<<' do
      it 'pushes the log message onto the logger_queue' do
        expect(em_logger.logger_queue).to receive('push').once
        em_logger << 'this is a test'
      end
    end
  end

  describe 'queuing' do
    describe '#add' do
      context 'when logging below the defined level' do
        it 'pushes the log message onto the logger_queue' do
          logger.level = ::Logger::WARN
          em_logger = EventMachine::Logger.new(logger, batch_size: 1)
          expect(em_logger.logger_queue).to_not receive('push')
          expect(em_logger.add(::Logger::INFO, 'this is a test')).to be_truthy
        end
      end

      context 'when logging above the defined level' do
        it 'pushes the log message onto the logger_queue' do
          em_logger = EventMachine::Logger.new(logger, batch_size: 1)
          expect(em_logger.logger_queue).to receive('push').once
          em_logger.add(::Logger::INFO, 'this is a test')
        end
      end

      context 'when using a block' do
        it 'evaluates the block' do
          em_logger = EventMachine::Logger.new(logger, batch_size: 1)
          expect(em_logger.logger_queue).to receive('push').once
          em_logger.add(::Logger::INFO) { 'ohai' }
        end
      end
    end
  end

  describe 'delegating to logger' do
    describe 'method_missing' do
      it 'passes through to the underlying logger' do
        em_logger = EventMachine::Logger.new(logger)
        expect(logger).to receive('level').once
        em_logger.level
      end

      it 'returns the underlying loggers value' do
        logger.level = ::Logger::WARN
        em_logger = EventMachine::Logger.new(logger)
        expect(em_logger.level).to eq(::Logger::WARN)
      end
    end

    describe 'respond_to?' do
      it 'responds to methods defined on the logger' do
        em_logger = EventMachine::Logger.new(logger)
        expect(em_logger.respond_to?('level')).to be_truthy
      end
    end
  end

  context 'when messages less than batch size' do
    it 'does not touch the logger' do
      em_logger = EventMachine::Logger.new(logger, batch_size: 2)
      expect(logger).to_not receive(:add)
      EM.run_block do
        em_logger.info('First log')
      end
    end

    context 'when several messages' do
      it 'does not touch the logger' do
        em_logger = EventMachine::Logger.new(logger, batch_size: 2)
        expect(logger).to receive(:add).twice
        EM.run_block do
          em_logger.info('First log')
          em_logger.info('First log')
        end
      end
    end
  end

end
