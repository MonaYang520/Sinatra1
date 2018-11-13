require 'sinatra'
require 'sinatra/reloader' if development?
require 'dm-core'
require 'dm-migrations'

configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
end

class Student
  include DataMapper::Resource
  property :id, Serial
  property :firstname, String
  property :lastname, String
  property :gender, String
  property :birthdate, Date
  property :phone, String
  
  def birthdate=date
    super Date.strptime(date, '%m/%d/%Y')
  end
end

DataMapper.finalize

get '/students' do
  @students = Student.all
  slim :students
end

get '/students/new' do
  redirect to("/login") unless session[:admin]
  @student = Student.new
  slim :new_student
end

get '/students/:id' do
  @student = Student.get(params[:id])
  slim :show_student
end

get '/students/:id/edit' do
  redirect to("/login") unless session[:admin]
  @student = Student.get(params[:id])
  slim :edit_student
end

post '/students' do  
  student = Student.create(params[:student])
  redirect to("/students/#{student.id}")
end

put '/students/:id' do
  student = Student.get(params[:id])
  student.update(params[:student])
  redirect to("/students/#{student.id}")
end

delete '/students/:id' do
  redirect to("/login") unless session[:admin]
  Student.get(params[:id]).destroy
  redirect to('/students')
end
