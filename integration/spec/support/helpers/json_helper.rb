require 'httparty'
require 'jwe'
require 'open-uri'

module JsonHelper
  def wait_for_request
    submission_path = "#{base_adapter_domain}/submission"
    tries = 0
    max_tries = 20

    until tries > max_tries
      puts "GET #{submission_path}"
      response = HTTParty.get(submission_path, **{ open_timeout: 10, read_timeout: 5 })

      if response.code == 200
        break
      else
        sleep 3
        tries += 1
      end
    end

    if tries == max_tries || response.code != 200
      raise "Base adapter didn't receive the submission: Adapter response: '#{response.body}'"
    else
      JSON.parse(
        response.body,
        symbolize_names: true
      )
    end
  end

  def delete_adapter_submissions
    HTTParty.delete(
      "#{base_adapter_domain}/submissions",
      **{ open_timeout: 10, read_timeout: 10 }
    )
  end

  def base_adapter_domain
    ENV.fetch('FORM_BUILDER_BASE_ADAPTER_ENDPOINT')
  end
end
