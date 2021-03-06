module Selenium
  module WebDriver
    module IE

      #
      # @api private
      #

      class Bridge < Remote::Bridge

        HOST            = Platform.localhost
        DEFAULT_PORT    = 5555
        DEFAULT_TIMEOUT = 30

        def initialize(opts = {})
          timeout     = opts.delete(:timeout) { DEFAULT_TIMEOUT }
          @port       = opts.delete(:port) { DEFAULT_PORT }
          @speed      = opts.delete(:speed) { :fast }
          http_client = opts.delete(:http_client)

          unless opts.empty?
            raise ArgumentError, "unknown option#{'s' if opts.size != 1}: #{opts.inspect}"
          end

          @server_pointer = Lib.start_server @port

          host = Platform.localhost
          unless SocketPoller.new(host, @port, timeout).connected?
            raise Error::WebDriverError, "unable to connect to IE server within #{timeout} seconds"
          end

          remote_opts = {
            :url => "http://#{host}:#{@port}",
            :desired_capabilities => :firefox
          }

          remote_opts.merge!(:http_client => http_client) if http_client

          super(remote_opts)
        end

        def browser
          :internet_explorer
        end

        def driver_extensions
          [DriverExtensions::TakesScreenshot, DriverExtensions::HasInputDevices]
        end

        def quit
          super
          Lib.stop_server(@server_pointer)

          nil
        end

      end # Bridge
    end # IE
  end # WebDriver
end # Selenium
