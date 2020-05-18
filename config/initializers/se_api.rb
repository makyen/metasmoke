# frozen_string_literal: true
module SE
  class API
    include Singleton

    attr_accessor :logger

    def get_response(uri_or_host, path:nil, port:nil, &block)
      setup_logger

      resp = Net::HTTP.get_response(uri_or_host, path:path, port:port, &block)
      if resp.code.start_with? '2'
        logger.info "#{resp.code} GET #{uri_or_host}"
      else
        logger.error "#{resp.code} on GET to #{uri_or_host}"
        logger.error 'Following: uri_or_host, path, port, response body'
        logger.error uri_or_host.to_s
        logger.error path.to_s
        logger.error port.to_s
        logger.error resp.body
        logger.error ''
        logger.error ' ===================================================== '
        logger.error ''
      end
      resp
    end

    private

    def msg2str(msg)
      case msg
      when ::String
        msg
      when ::Exception
        "#{msg.message} (#{msg.class})\n" <<
          (msg.backtrace || []).join("\n")
      else
        msg.inspect
      end
    end

    private

    def setup_logger
      return if logger.present?

      logger = ::Logger.new(Rails.root.join('log', 'se-api-errors.log').to_s)
      logger.level = :debug

      logger.formatter = proc do |severity, time, progname, msg|
        "%s, [%s #%d] %5s -- %s: %s\n" % [severity[0..0], time.strftime('%Y-%m-%d %H:%M:%S'), $$, severity, progname,
                                          msg2str(msg)]
      end
    end
  end
end

StackAPIHelper = SE::API.instance
