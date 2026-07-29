# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

use Rack::MethodOverride
JSON_FILE = 'memo.json'

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memos = load_memos
  memos[SecureRandom.uuid.to_sym] = { title: params[:title], content: params[:content] }
  save_memos(JSON_FILE, memos)
  redirect '/memos'
end

get '/memos/:id' do
  @memo = load_memos[params[:id].to_sym]
  erb :show
end

get '/memos/:id/edit' do
  @memo = load_memos[params[:id].to_sym]
  erb :edit
end

patch '/memos/:id' do
  memos = load_memos
  memo = memos[params[:id].to_sym]
  memo[:title] = params[:title]
  memo[:content] = params[:content]
  save_memos(JSON_FILE, memos)
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memos = load_memos
  memos.delete(params[:id].to_sym)
  save_memos(JSON_FILE, memos)
  redirect '/memos'
end

def load_memos
  JSON.parse(File.read(JSON_FILE), symbolize_names: true)
end

def save_memos(file_path, memos)
  File.open(file_path, 'w') do |file|
    file.write(JSON.generate(memos))
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
