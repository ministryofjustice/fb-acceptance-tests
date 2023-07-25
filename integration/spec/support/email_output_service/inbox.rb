require 'pdf-reader'

class Inbox
  USER_ID = 'me'.freeze
  attr_reader :service

  def initialize(service)
    @service = service
  end

  def all
    messages.map do |message|
      email = service.get_user_message(USER_ID, message.id)
      subject = Array(
        email.payload.headers
      ).find { |header| header.name == 'Subject' }&.value
      reply_to = Array(
        email.payload.headers
      ).find { |header| header.name == 'Reply-To' }&.value
      from = Array(
        email.payload.headers
      ).find { |header| header.name == 'From' }&.value

      AcceptanceTestEmail.new(
        email_id: email.id,
        subject: subject,
        snippet: email.snippet,
        attachments: all_attachments_for(email),
        raw: email,
        reply_to: reply_to,
        from: from
      )
    end
  end

  def remove_emails(emails)
    emails.each do |email|
      service.trash_user_message(USER_ID, email.email_id)
    end
  end


  private

  def messages
    Array(service.list_user_messages(USER_ID).messages)
  end

  def all_attachments_for(message)
    all_attachments = { csvs: [], pdf_answers: nil, file_upload: nil }

    return all_attachments if message.payload.blank?

    message.payload.parts.each do |part|
      next if part.filename.empty?

      data = part.body.data
      if data.blank?
        data = service.get_user_message_attachment(
          USER_ID,
          message.id,
          part.body.attachment_id
        ).data
      end

      if part.mime_type == 'application/pdf'
        all_attachments[:pdf_answers] = data
      elsif part.mime_type == 'text/plain'
        all_attachments[:multi_uploads] = all_attachments[:multi_uploads].present? ? all_attachments[:multi_uploads] + data : data
        all_attachments[:file_upload] = data
      elsif part.filename.include?('.csv')
        all_attachments[:csvs] << data
      end
    end

    all_attachments
  end
end

class AcceptanceTestEmail < OpenStruct
end
