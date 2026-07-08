# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
use Rack::MethodOverride
set :erb, escape_html: true

get '/' do
  @memo_data = parse_json
  erb :index
end

get '/memo/new' do
  erb :new
end

post '/memo/new' do
  memo_data = parse_json
  new_memo = { title: params[:title], content: params[:content] }
  memo_data[:data] << new_memo
  File.open('MemoData.json', 'w') do |file|
    file.write(JSON.pretty_generate(memo_data))
  end
  redirect '/'
end

get '/memo/:id' do
  @memo_data = parse_json[:data][params[:id].to_i - 1]
  erb :show
end

get '/memo/:id/edit' do
  @memo_data = parse_json[:data][params[:id].to_i - 1]
  erb :edit
end

patch '/memo/:id/update' do
  memo_data = parse_json
  memo_data[:data][params[:id].to_i - 1][:title] = params[:title]
  memo_data[:data][params[:id].to_i - 1][:content] = params[:content]
  File.open('MemoData.json', 'w') do |file|
    file.write(JSON.pretty_generate(memo_data))
  end
  redirect "/memo/#{params[:id].to_i}"
end

delete '/memo/:id/delete' do
  memo_data = parse_json
  memo_data[:data].delete_at(params[:id].to_i - 1)
  File.open('MemoData.json', 'w') do |file|
    file.write(JSON.pretty_generate(memo_data))
  end
  redirect '/'
end

def parse_json
  JSON.parse(File.read('MemoData.json'), symbolize_names: true)
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
