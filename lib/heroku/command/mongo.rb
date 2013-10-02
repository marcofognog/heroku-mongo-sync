module Heroku::Command
  class Mongo < BaseWithApp
    def initialize(*args)
      super

      require 'mongo'
    rescue LoadError
      error "Install the Mongo gem to use mongo commands:\nsudo gem install mongo"
    end

    def push
      collection_names = @args.any? ? @args : nil
      pretty_collection_names = collection_names ? collection_names.join(",") : "ALL DATA"
      display "THIS WILL REPLACE #{pretty_collection_names} IN #{app} ON #{heroku_mongo_uri.host} WITH #{local_mongo_uri.host}"
      display "Are you sure? (y/n) ", false
      return unless ask.downcase == 'y'
      transfer(local_mongo_uri, heroku_mongo_uri, collection_names)
    end

    def pull
      display "Replacing the #{app} db at #{local_mongo_uri.host} with #{heroku_mongo_uri.host}"
      transfer(heroku_mongo_uri, local_mongo_uri, collection_names)
    end

    protected
      def transfer(from, to, collection_names=nil)
        raise "The destination and origin URL cannot be the same." if from == to
        origin = make_connection(from)
        dest   = make_connection(to)

        collections = origin.collections.select { |col| collection_names.nil? || collection_names.include?(col.name) }
        collections.each do |col|
          next if col.name =~ /^system\./

          dest.drop_collection(col.name)
          dest_col = dest.create_collection(col.name)

          col.find().each_with_index do |record, index|
            dest_col.insert record
            display_progress(col, index)
          end

          display "\n done"
        end

        display "Syncing indexes...", false
        dest_index_col = dest.collection('system.indexes')
        origin_index_col = origin.collection('system.indexes')
        origin_index_col.find().each do |index|
          index['ns'] = index['ns'].sub(origin_index_col.db.name, dest_index_col.db.name)
          dest_index_col.insert index
        end
        display " done"
      end

      def heroku_mongo_uri
        config = Heroku::Auth.api.get_config_vars(app).body
        url    = config['MONGO_URL'] || config['MONGOHQ_URL'] || config['MONGOLAB_URI']
        error("Could not find the MONGO_URL for #{app}") unless url
        make_uri(url)
      end

      def local_mongo_uri
        url = ENV['MONGO_URL'] || "mongodb://localhost:27017/#{app}"
        make_uri(url)
      end

      def make_uri(url)
        urlsub = url.gsub('local.mongohq.com', 'mongohq.com')
        uri = URI.parse(urlsub)
        raise URI::InvalidURIError unless uri.host
        uri
      rescue URI::InvalidURIError
        error("Invalid mongo url: #{url}")
      end

      def make_connection(uri)
        connection = ::Mongo::Connection.new(uri.host, uri.port)
        db = connection.db(uri.path.gsub(/^\//, ''))
        db.authenticate(uri.user, uri.password) if uri.user
        db
      rescue ::Mongo::ConnectionFailure
        error("Could not connect to the mongo server at #{uri}")
      end

      def display_progress(col, index)
        count = col.size
        if (index + 1) % step(col) == 0
          display(
            "\r#{"Syncing #{col.name}: %d of %d (%.2f%%)... " %
            [(index+1), count, ((index+1).to_f/count * 100)]}",
            false
          )
        end
      end

      def step(col)
        step  = col.size / 100000 # 1/1000 of a percent
        step  = 1 if step == 0
      end

      Help.group 'Mongo' do |group|
        group.command 'mongo:push', 'push the local mongo database'
        group.command 'mongo:pull', 'pull from the production mongo database'
      end
  end
end
