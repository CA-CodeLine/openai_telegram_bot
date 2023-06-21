# frozen_string_literal: true

Dir['./app/services/*.rb'].sort.each { |file| require file }

require 'telegram/bot'
require 'rest-client'

class BotService < ApplicationService
  def initialize(data)
    @bot = Telegram::Bot::Api.new(TOKEN)
    @updater = Telegram::Bot::Types::Update.new(data)
    @message = @updater&.message
    @callback_query = @updater.callback_query
    execute
  end

  def execute
    messages_queries if @message
    callback_queries if @callback_query
  rescue StandardError => e
    puts e
    true
  end

  private

  def callback_queries
    @message = @callback_query.message

    @telegram_id = if @message.chat.type == 'private'
                     @message.chat.id
                   else
                     0 # TODO: fix to when this bot is on group
                   end
  end

  def messages_queries
    return unless @message.text

    @telegram_id = if @message.chat.type == 'private'
                     @message.chat.id
                   else
                     0 # TODO: fix to when this bot is on group
                   end
    start_message if @message.text.start_with?('/start')
    select_version if @message.text.start_with?('/ask')
  end

  # message queries

  def start_message
    message = t('welcome')
    @bot.send_message(chat_id: @message.chat.id, text: message, parse_mode: 'HTML')
  end

  def select_version
    message = t('choose_version')
    @prompt = @message.text[5, @message.text.length - 1]

    return unless @prompt

    message = ChatGpt.new.ask(prompt: @prompt)
    message = t('not_found') unless message && message != ''

    @prompt = nil
    @bot.send_message(chat_id: @message.chat.id, text: message, parse_mode: 'HTML')
  end

  # callback queries
end
