require 'pp'
require 'koala'
require 'pstore'
require './alchemyapi_ruby/alchemyapi'

KAP_UID   = "10153861133104045"
WILL_UID  = "10155669700855217"
ALLEN_UID = "10202937310033920"
OAUTH_ACCESS_TOKEN = "CAAL7RxuBkLMBAPQv33sMVVDgKDJ1jMT3DF8BWqYThazqR1QyqpddRWtkc8ImZARgkFBRUUO5TqH60QrfvEKfyRu1XAUTlYLV59RuMCt242KtzSLeSRrFii4ZCFi8ZBZBzDc2DvpIrDrh4JdKD1kPnp2tGgVollel6KPuTdgV4qtKu8YGokFPyNvGZAZBUu600ZD"

# prep
$graph = Koala::Facebook::API.new(OAUTH_ACCESS_TOKEN)
$nlp   = AlchemyAPI.new()
$store = PStore.new("data.pstore")

class User
    attr_accessor :uid, :profile, :places, :likes, :statuses, :friends

    def self.get(uid, load_friends = true)
        user = $store.transaction do
            $store.fetch(uid, nil)
        end

        if user.nil?
            user = User.new(uid, load_friends)
            $store.transaction do
                $store[uid] = user
            end
        end

        user
    end

    def initialize(uid, load_friends = true)
        @uid      = uid
        @profile  = $graph.get_object(uid)

        puts "loading #{name}"
        @places   = get_all("tagged_places")
        @likes    = get_all("likes")
        @statuses = get_all("statuses")
        
        if load_friends
            puts "getting friends"
            app_friends = $graph.get_connections(@uid, "friends")
            @friends = app_friends.collect do |friend|
                User.get(friend['id'], false).uid
            end
        else
            @friends = []
        end
    end

    def get_all(type)
        puts "\tgetting all #{type}"
        all = []
        rows = $graph.get_connections(@uid, type)
        while !rows.nil? && rows.length > 0 && all.length <= 1000
            all += rows
            puts "\t\t#{all.length}"
            rows = rows.next_page
        end

        all
    end

    def name
        @profile['name']
    end

    def birthday
        @profile['birthday']
    end

    def update_likes
        @likes = get_all("likes")
    end
    
    def link_statuses
        puts "linking"
        @statuses.each_with_index do |status, i|
            puts "\t#{i}"
            next if status['message'].nil? || status['nlp']
            response = $nlp.concepts('text', status['message'])
            next if response['status'] != 'OK'
            status['nlp'] = response['concepts']
        end

        user = self
        $store.transaction do
            $store[uid] = user
        end
    end

    def ranked_entities
        sums = Hash.new(0)
        counts = Hash.new(0)

        @statuses.each do |status|
            next unless status['nlp']
            status['nlp'].each do |entity|
                sums[entity['text']] += entity['relevance'].to_f
                counts[entity['text']] += 1
            end
        end

        names = sums.keys
        avgs = {}
        sums.each do |name, sum|
            avgs[name] = sum / counts[name]
        end

        sums.keys.sort_by {|name| counts[name]}.reverse
    end
end

# query
user = User.get(WILL_UID)
#user.link_statuses
#p user.statuses[4]['nlp']
p user.ranked_entities[0..10]



