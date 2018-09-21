require 'websocket/driver'
require 'socket'
require 'forwardable'
require 'celluloid/current'
require 'celluloid/io'

module Slack
  module RealTime
    module Concurrency
      module Celluloid
        class Socket < Slack::RealTime::Socket
          include ::Celluloid::IO
          include ::Celluloid::Internals::Logger

          BLOCK_SIZE = 4096

          extend ::Forwardable
          def_delegators :driver, :text, :binary

          attr_reader :socket

          def initialize(*args)
            super
          end

          def connect!
            super
            run_loop
          end

          def run_loop
            @closing = false
            @socket = build_socket
            @connected = @socket.connect
            driver.start
            loop { read } if socket
          rescue EOFError, Errno::ECONNRESET, Errno::EPIPE => e
            logger.debug("#{self.class}##{__method__}") { e }
            driver.emit(:close, WebSocket::Driver::CloseEvent.new(1001, 'server closed connection')) unless @closing
          ensure
            begin
              current_actor.terminate if current_actor.alive?
            rescue StandardError
              nil
            end
          end

          def close
            @closing = true
            driver.close
            super
          end

          def read
            buffer = socket.readpartial(BLOCK_SIZE)
            raise EOFError unless buffer && !buffer.empty?
            async.handle_read(buffer)
          end

          def handle_read(buffer)
            logger.debug("#{self.class}##{__method__}") { buffer }
            driver.parse buffer
          end

          def write(data)
            logger.debug("#{self.class}##{__method__}") { data }
            socket.write(data)
          end

          def start_async(client)
            Thread.new do
              client.run_loop
            end
          end

          def connected?
            !@connected.nil?
          end

          protected

          def build_socket
            socket = ::Celluloid::IO::TCPSocket.new(addr, port)
            socket = ::Celluloid::IO::SSLSocket.new(socket, build_ssl_context) if secure?
            socket
          end

          def build_ssl_context
            OpenSSL::SSL::SSLContext.new(:TLSv1_2_client)
          end

          def build_driver
            ::WebSocket::Driver.client(self)
          end

          def connect
            @driver = build_driver
          end
        end
      end
    end
  end
end
