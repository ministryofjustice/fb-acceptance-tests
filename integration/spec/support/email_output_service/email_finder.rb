require_relative 'google_service'

class EmailFinder
  attr_accessor :id, :expected_emails, :find_criteria

  def initialize(
    service:,
    id:,
    expected_emails: nil,
    find_criteria: nil
  )
    @service = service.new.authenticated_service
    @id = id
    @find_criteria = find_criteria || :subject
    @expected_emails = expected_emails || 2
    @inbox = Inbox.new(@service)
  end

  def email_received?
    emails.size == @expected_emails
  end

  def emails
    @filtered_emails ||= if find_criteria == :subject
      all_by_subject
    else
      all_by_attachment
    end
  end

  def attachments
    hash = {}

    @filtered_emails.each do |email|
      hash.merge!(email.attachments.reject { |_,v| v.blank? })
    end

    hash
  end

  def remove_emails
    inbox.remove_emails(@filtered_emails) if @filtered_emails.present?
  end

  private

  def all_by_subject
    inbox.all.select do |email|
      puts "Looking for subject with #{id} in #{email.subject}"
      email.subject.include?(id)
    end
  end

  def all_by_attachment
    inbox.all.select do |email|
      if email.attachments[:pdf_answers]
        pdf_path = "/tmp/submission-#{SecureRandom.uuid}.pdf"
        File.open(pdf_path, 'w') do |file|
          file.write(email.attachments[:pdf_answers])
        end
        result = PDF::Reader.new(pdf_path).pages.map do |page|
          page.text
        end.join(' ')

        puts "Looking for attachment with #{id} in #{email.subject}"
        if result.include?(id)
          puts "=" * 80
          puts "Found in #{email.subject}! #{id}"
          puts "=" * 80
        end
        result.include?(id)
      end
    end
  end

  attr_reader :service, :pdf_filename, :user_attachment_filename, :inbox
end
