require 'sinatra'
require 'sinatra/reloader' if development?
require 'dm-core'
require 'dm-migrations'

configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/comment.db")
end

configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
end

class Comment
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :person_name, String
  property :created_at, DateTime, :default => DateTime.now
  property :content, String

end

DataMapper.finalize

get '/comments' do
  @comments = Comment.all
  slim :comments
end

get '/comments/new' do
  redirect to("/login") unless session[:admin]
  @comment = Comment.new
  slim :new_comment
end

get '/comments/:id' do
  @comment = Comment.get(params[:id])
  slim :show_comment
end

post '/comments' do
  comment = Comment.create(params[:comment])
  redirect to("/comments/#{comment.id}")
end

put '/comments/:id' do
  comment = Comment.get(params[:id])
  comment.update(params[:comment])
  redirect to("/comments/#{comment.id}")
end

delete '/comments/:id' do
  redirect to("/login") unless session[:admin]
  Comment.get(params[:id]).destroy
  redirect to('/comments')
end
