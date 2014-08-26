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
    results = conn.exec('SELECT id, name FROM actors ORDER BY name')
    @actors = results.to_a
  end

  erb :'actors/index'
  #binding.pry
end

get '/movies' do
  db_connection do |conn|
    results = conn.exec('SELECT movies.id AS id, movies.title AS movie, movies.year AS year, movies.rating AS rating,
      genres.name AS genre, studios.name AS studio
      FROM movies
      JOIN genres ON movies.genre_id = genres.id
      JOIN studios ON movies.studio_id = studios.id
      ORDER BY movie')
    @movies = results.to_a
    #binding.pry
  end
  erb :'movies/index'
end


