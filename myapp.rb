# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
use Rack::MethodOverride
JSON_FILE = 'memo_data.json'

get '/' do
  @memo_data = parse_json
  erb :index
end

get '/memo/new' do
  erb :new
end

post '/memo' do
  memo_data = parse_json
  new_id = memo_data[:data].empty? ? 1 : memo_data[:data][-1][:id] + 1
  new_memo = { id: new_id, title: params[:title], content: params[:content] }
  memo_data[:data] << new_memo
  File.open(JSON_FILE, 'w') do |file|
    file.write(JSON.pretty_generate(memo_data))
  end
  redirect '/'
end

get '/memo/:id' do
  @memo_data = parse_json[:data].find { |memo| memo[:id] == params[:id].to_i }
  erb :show
end

get '/memo/:id/edit' do
  @memo_data = parse_json[:data].find { |memo| memo[:id] == params[:id].to_i }
  erb :edit
end

patch '/memo/:id' do
  memo_data = parse_json
  update_memo_data = memo_data[:data].find { |memo| memo[:id] == params[:id].to_i }
  update_memo_data[:title] = params[:title]
  update_memo_data[:content] = params[:content]

  File.open(JSON_FILE, 'w') do |file|
    file.write(JSON.pretty_generate(memo_data))
  end
  redirect "/memo/#{params[:id].to_i}"
end

delete '/memo/:id' do
  memo_data = parse_json
  memo_data[:data].delete_if { |memo| memo[:id] == params[:id].to_i }
  File.open(JSON_FILE, 'w') do |file|
    file.write(JSON.pretty_generate(memo_data))
  end
  redirect '/'
end

def parse_json
  JSON.parse(File.read(JSON_FILE), symbolize_names: true)
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
