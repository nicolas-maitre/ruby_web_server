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
redis.set "level", {
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

# definition d'un level par id
redis.hmset('level:1', :name, 'level 01', :difficulty, 'easy', 
:music, {
    "id": 2,
    "name": "tryhard",
    "duration": 120000
}.to_json, 
:sequence, [
    {
        "time": 1200, 
        "key": "z",
        "duration": 0
    }
].to_json, 
:textures, {
    "tree": "normal", 
    "platform": "normal"
}.to_json,
:creator, {
    "id": 1,
    "name": "diogo"
}.to_json,
:hardcore, "false")

redis.hmset('level:2', :name, 'level 02', :difficulty, 'easy', 
:music, {
    "id": 2,
    "name": "tryhard",
    "duration": 120000
}.to_json, 
:sequence, [
    {
        "time": 1200, 
        "key": "z",
        "duration": 0
    }
].to_json, 
:textures, {
    "tree": "normal", 
    "platform": "normal"
}.to_json,
:creator, {
    "id": 1,
    "name": "diogo"
}.to_json,
:hardcore, "true")

# get 1 param
redis.hget('level:1', :name)
# get multi param
redis.hmget('level:1', :name, :hardcore, :difficulty)
redis.hget('level:2', :name) 
redis.hmget('level:2', :name, :hardcore, :difficulty)