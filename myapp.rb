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
  new_memo = { id: SecureRandom.uuid, title: params[:title], content: params[:content] }
  memo[:data] << new_memo
  File.open(JSON_FILE, 'w') do |file|
    file.write(JSON.generate(memo))
  end
  redirect '/memos'
end

get '/memos/:id' do
  @memo = load_memo[:data].find { |memo| memo[:id] == params[:id] }
  erb :show
end

get '/memos/:id/edit' do
  @memo = load_memo[:data].find { |memo| memo[:id] == params[:id] }
  erb :edit
end

patch '/memos/:id' do
  memo = load_memo
  update_memo = memo[:data].find { |memo| memo[:id] == params[:id] }
  update_memo[:title] = params[:title]
  update_memo[:content] = params[:content]

  File.open(JSON_FILE, 'w') do |file|
    file.write(JSON.pretty_generate(memo))
  end
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memo = load_memo
  memo[:data].delete_if { |memo| memo[:id] == params[:id] }
  File.open(JSON_FILE, 'w') do |file|
    file.write(JSON.pretty_generate(memo))
  end
  redirect '/memos'
end

def load_memo
  if File.exist?(JSON_FILE)
    JSON.parse(File.read(JSON_FILE), symbolize_names: true)
  else
    { data: [] }
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
