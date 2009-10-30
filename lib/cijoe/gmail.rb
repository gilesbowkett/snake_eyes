# The CI Joe Gmail notifier is a mashup of two pieces of code.
#
# 1) This gist:
#
# http://gist.github.com/122071
#
# 2) The CI Joe Campfire notifier.
#
# The CI Joe Campfire notifier uses a valid_config? method to check that the notifier will be able to work. If so, it loads
# the Campfire module right into CI Joe, so that when CI Joe calls #notify, it's calling the #notify on the Campfire module.
# Obviously, even though Chris was very explicit about not supporting any kind of notifier except the Campfire notifier, this
# is a very, very extensible API which is very, very friendly to repurposing. So I made with the repurpose. All you need to
# support is an #activate method on the module itself and a #notify instance method. Copying the #valid_config? pattern is
# strongly advised but absolutely not required.

class CIJoe
  module Gmail
    def self.activate
      if valid_config?
        require "openssl"
        require "net/smtp"

        # http://www.jamesbritt.com/2007/12/18/sending-mail-through-gmail-with-ruby-s-net-smtp
        # http://d.hatena.ne.jp/zorio/20060416

        Net::SMTP.class_eval do
          private
          def do_start(helodomain, user, secret, authtype)
            raise IOError, 'SMTP session already started' if @started
            check_auth_args user, secret, authtype if user or secret

            sock = timeout(@open_timeout) { TCPSocket.open(@address, @port) }
            @socket = Net::InternetMessageIO.new(sock)
            @socket.read_timeout = 60 #@read_timeout
            @socket.debug_output = STDERR #@debug_output

            check_response(critical { recv_response() })
            do_helo(helodomain)

            raise 'openssl library not installed' unless defined?(OpenSSL)
            starttls
            ssl = OpenSSL::SSL::SSLSocket.new(sock)
            ssl.sync_close = true
            ssl.connect
            @socket = Net::InternetMessageIO.new(ssl)
            @socket.read_timeout = 60 #@read_timeout
            @socket.debug_output = STDERR #@debug_output
            do_helo(helodomain)

            authenticate user, secret, authtype if user
            @started = true
          ensure
            unless @started
              # authentication failed, cancel connection.
                @socket.close if not @started and @socket and not @socket.closed?
              @socket = nil
            end
          end

          def do_helo(helodomain)
             begin
              if @esmtp
                ehlo helodomain
              else
                helo helodomain
              end
            rescue Net::ProtocolError
              if @esmtp
                @esmtp = false
                @error_occured = false
                retry
              end
              raise
            end
          end

          def starttls
            getok('STARTTLS')
          end
        end

        CIJoe::Build.class_eval do
          include CIJoe::Gmail
        end

        puts "Loaded Gmail notifier"
      else
        puts "Can't load Gmail notifier."
        puts "Please add the following to your project's .git/config:"
        puts "[gmail]"
        puts "\tuser = your_ci_joe@email"
        puts "\tpass = passw0rd"
        puts "\trecipient = developers@your-company.com"
      end
    end

    def self.config
      @config ||= {
        :user      => Config.gmail.user.to_s,
        :pass      => Config.gmail.pass.to_s
      }
    end

    def self.valid_config?
      %w( user pass recipient ).all? do |key|
        !config[key.intern].empty?
      end
    end

    def notify
      send_email(@config[:user],
                 "Vidli Continuous Integration",
                 @config[:recipient],
                 @config[:recipient],
                 short_message,
                 "#{full_message}\n#{commit.url}")
    end

    private
    # http://snippets.dzone.com/posts/show/2362
    def send_email(from, from_alias, to, to_alias, subject, message)
      msg = <<END_OF_MESSAGE
From: #{from_alias} <#{from}>
To: #{to_alias} <#{to}>
Subject: #{subject}

#{message}
END_OF_MESSAGE

      Net::SMTP.start("smtp.gmail.com",
                      587,
                      "localhost.localdomain",
                      @config[:user],
                      @config[:pass],
                      "plain") do |smtp|
        smtp.send_message msg, from, to
      end
    end

  end
end

