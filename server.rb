require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

get '/actors' do
  db_connection do |conn|
    results = conn.exec('SELECT name FROM actors ORDER BY name')
    @actors = results.to_a
  end

  erb :'actors/index'
  #binding.pry
end

get '/movies' do

  erb :'movies/index'
end


