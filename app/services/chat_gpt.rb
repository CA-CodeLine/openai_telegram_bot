require 'net/http'
require 'json'

class ChatGpt
  def initialize
    @token = ENV['OPEN_AI_TOKEN']
  end

  def ask(prompt:)
    return unless prompt && prompt != ''

    url = URI.parse("https://api.openai.com/v1/engines/text-davinci-003/completions")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url.path)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@token}"

    data = {
      'prompt': prompt,
      'max_tokens': 50,
      'temperature': 0.7,
      top_p: 1.0,
      n: 1
    }

    request.body = data.to_json

    response = http.request(request)
    json_response = JSON.parse(response.body)

    choices = json_response['choices']
    return choices[0]['text'] if choices && choices.length > 0

    return nil
  end
end
