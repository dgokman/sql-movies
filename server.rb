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

end

get '/actors/:id' do
  @actor_id = params[:id]
  db_connection do |conn|
    results = conn.exec_params('SELECT movies.title AS movie, movies.id AS movie_id,
      cast_members.character AS role,cast_members.actor_id AS actor_id,
      actors.id AS id, cast_members.movie_id AS cast_movie_id, actors.name AS actor
      FROM cast_members
      JOIN movies ON movies.id = cast_members.movie_id
      JOIN actors ON actors.id = cast_members.actor_id
      WHERE actors.id = $1', [@actor_id])
    @actors_id = results.to_a

  end
  erb :'actors/show'
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

  end
  erb :'movies/index'
end

get '/movies/:id' do
  @movie_id = params[:id]
  db_connection do |conn|
    results = conn.exec_params('SELECT movies.id AS id, movies.title AS movie, movies.year AS year, actors.name AS actor,
      genres.name AS genre, studios.name AS studio, cast_members.movie_id AS cast_movie_id, cast_members.character AS role,
      cast_members.actor_id AS actor_id, actors.id AS actor_id_f
      FROM movies
      JOIN genres ON movies.genre_id = genres.id
      JOIN studios ON movies.studio_id = studios.id
      JOIN cast_members ON movies.id = cast_members.movie_id
      JOIN actors on actors.id = cast_members.actor_id
      WHERE movies.id = $1',[@movie_id])
    @movies_id = results.to_a
  end

  erb :'movies/show'
end


