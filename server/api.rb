require 'redis'
require 'json'

# établir une connection avec la db
$redis = Redis.new(:host=> "127.0.0.1", :port => 6379, :db => 1)

# permet de savoir si nous avons bien eu une connection
# grace à la réponce PONG
puts $redis.ping

# params : get values with an array of attributes
def selectValue(table,id,params)
    return [] unless params.class == Array && id.class == Integer
    
    for i in params do
        return [] unless i.class == String
    end

    $redis.hmget("#{table}:#{id}", "id")
end

def selectAll(table,id)
    if id.is_a?(Integer) then
        $redis.hgetall("#{table}:#{id}") 
    else 
        ["error"]
    end
end

# params : first value name of attribut and next is the value
# exemple : ["id", "name"]
def insert(table,id,params)
    return [] unless params.class == Array 

    $redis.hmset("#{table}:#{id}" , params)
end

insert("a", 3, ["id",3])
puts selectAll("a",3) # receive data
puts selectAll("a","5") # doesn't receive


puts selectValue("a","5","id")#doesn't work zone
puts selectValue("a",3,["id"])