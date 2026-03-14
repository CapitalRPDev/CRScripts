-- Webhook for instapic posts, recommended to be a public channel
INSTAPIC_WEBHOOK = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C"
-- Webhook for birdy posts, recommended to be a public channel
BIRDY_WEBHOOK = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C"

-- Discord webhook or API key for server logs
-- We recommend https://fivemanage.com/ for logs. Use code "LBLOGS" for 20% off the Logs Pro plan
LOGS = {
    Default = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C", -- set to false to disable
    Calls = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Messages = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    InstaPic = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Birdy = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    YellowPages = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Marketplace = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Mail = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Wallet = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    DarkChat = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Services = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Crypto = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Trendy = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C",
    Uploads = "https://discord.com/api/webhooks/1482528173076906202/5zTlnjI2PrYaB0bgdJ-G4gTu-LIrepvIe3SuVwPJfpiGpnu46TGOzvU9K7jTN6ULjv1C" -- all camera uploads will go here
}

DISCORD_TOKEN = nil -- you can set a discord bot token here to get the players discord avatar for logs

-- Set your API keys for uploading media here.
-- Please note that the API key needs to match the correct upload method defined in Config.UploadMethod.
-- The default upload method is Fivemanage
-- You can get your API keys from https://fivemanage.com/
-- Use code LBPHONE10 for 10% off on Fivemanage
-- A video tutorial for how to set up Fivemanage can be found here: https://www.youtube.com/watch?v=y3bCaHS6Moc
API_KEYS = {
    Video = "LZz91eF0d2UbyeIYxcbbxGbraWbivv1f",
    Image = "LZz91eF0d2UbyeIYxcbbxGbraWbivv1f",
    Audio = "LZz91eF0d2UbyeIYxcbbxGbraWbivv1f",
}

-- Here you can set your credentials for Config.DynamicWebRTC
-- This is needed if video calls or InstaPic live streams are not working
-- You can get your credentials from https://dash.cloudflare.com/?to=/:account/realtime/turn/overview
WEBRTC = {
    TokenID = nil,
    APIToken = nil,
}
