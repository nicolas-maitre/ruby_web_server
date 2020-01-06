require 'redis'

# établir une connection avec la db
redis = Redis.new
# ou
redis = Redis.new(:host=> "127.0.0.1", :port => 6379, :db => 1)

# permet de savoir si nous avons bien eu une connection
# grace à la réponce PONG
redis.ping

require 'json'

# définir une valeur
redis.set "level:1", {
    "id": 1,
    "name": "diogo",
    "difficulty": "easy",
    "music": {
        "id": 2,
        "name": "tryhard",
        "duration": 120000
    },
    "sequence": [
        {
            "time": 1200, 
            "key": "z",
            "duration": 0
        }
    ],
    "textures": {
        "tree": "normal", 
        "platform": "normal"
    },
    "creator": {
        "id": 1,
        "name": "diogo"
    },
    "hardcore": "false"
}.to_json
# récupérer la valeur
JSON.parse(redis.get("level"))

