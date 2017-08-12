#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

# before вызываеться каждый раз при перезагрузке
# любой страницы
before do
	# инициализация БД
	init_db
end

# configure вызываеться каждый раз при конфигурации приложения
# когда изменился код программы и перезагрузилась страница
configure do
	# инициализация БД
	init_db
	# создаёт таблицу если таблица не существует
	@db.execute 'create table if not exists Posts 
	(
		 id INTEGER PRIMARY KEY AUTOINCREMENT,
		 created_date DATE,
		 content TEXT
	)'
end


get '/' do
	#выбираем список постов из БД
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index			
end

# обработчик get-запроса /new
# (браузер получает страницу с сервера)
get '/new' do
 	erb :new
end
# обработчик post-запроса /new
# (браузер отправляет данные на сервер)
post '/new' do
	# получаем переменную из post запроса
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	# созранение данных в БД
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	# перенаправление на главную страницу
	redirect to '/'
end

# вывод информации о посте
get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]

	erb :details
end

