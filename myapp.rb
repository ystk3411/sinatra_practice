# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

use Rack::MethodOverride
JSON_FILE = 'memo.json'

get '/memos' do
  @memo = load_memo
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memo = load_memo
  new_memo = { SecureRandom.uuid.to_sym => {title: params[:title], content: params[:content]} }
  memo[SecureRandom.uuid.to_sym] = { title: params[:title], content: params[:content] }
  save_mamo(JSON_FILE, memo)
  redirect '/memos'
end

get '/memos/:id' do
  @memo = load_memo[params[:id].to_sym]
  erb :show
end

get '/memos/:id/edit' do
  @memo = load_memo[params[:id].to_sym]
  erb :edit
end

patch '/memos/:id' do
  memo = load_memo
  update_memo = memo[params[:id].to_sym]
  update_memo[:title] = params[:title]
  update_memo[:content] = params[:content]
  save_mamo(JSON_FILE, memo)
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memo = load_memo
  memo.delete(params[:id].to_sym)
  save_mamo(JSON_FILE, memo)
  redirect '/memos'
end

def load_memo
  if File.exist?(JSON_FILE)
    JSON.parse(File.read(JSON_FILE), symbolize_names: true)
  else
    { data: [] }
  end
end

def save_mamo(file_path, memo)
  File.open(file_path, 'w') do |file|
    file.write(JSON.generate(memo))
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
