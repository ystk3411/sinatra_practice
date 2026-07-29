# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'pg'

use Rack::MethodOverride
JSON_FILE = 'memo.json'

configure do
  conn = PG.connect(dbname: 'postgres')
  set :db_conn, conn

  settings.db_conn.exec <<-SQL
    CREATE TABLE IF NOT EXISTS memos (
      id SERIAL PRIMARY KEY,
      title VARCHAR(50) NOT NULL,
      content TEXT
    );
  SQL
end

get '/memos' do
  @memos = settings.db_conn.exec('SELECT * FROM memos')
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  content = params[:content]

  settings.db_conn.exec_params(
    'INSERT INTO memos (title, content) VALUES ($1, $2)',
    [title, content]
  )
  redirect '/memos'
end

get '/memos/:id' do
  @memo = settings.db_conn.exec_params('SELECT * FROM memos WHERE id = $1 LIMIT 1', [params[:id]])[0]
  erb :show
end

get '/memos/:id/edit' do
  @memo = settings.db_conn.exec_params('SELECT * FROM memos WHERE id = $1 LIMIT 1', [params[:id]])[0]
  erb :edit
end

patch '/memos/:id' do
  settings.db_conn.exec_params(
    'UPDATE memos SET title = $1, content = $2 WHERE id = $3',
    [params[:title], params[:content], params[:id]]
  )
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  settings.db_conn.exec_params('DELETE FROM memos WHERE id = $1', [params[:id]])
  redirect '/memos'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
