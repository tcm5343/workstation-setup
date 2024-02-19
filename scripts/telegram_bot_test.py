import requests

token = ''
user_id = ''
message = 'hi'

# Create url
api_url = f'https://api.telegram.org/bot{token}/sendMessage'

data = {
    'chat_id': user_id, 
    'text': message, 
    'parse_mode': 'MarkdownV2'
}

requests.post(api_url, data)

# https://core.telegram.org/bots/api#authorizing-your-bot
# https://core.telegram.org/bots/api#formatting-options

