#encoding: utf-8

require 'yaml'
require 'active_record'
require 'logger'
require 'digest/md5'

require 'uri'
require 'multi_json'

require 'sinatra'


=begin 
=================================================================
	读取配置文件
=================================================================
=end

$config = YAML.load_file 'api-server.yml'
server_conf = $config['server']
host = server_conf['host']
port = server_conf['port']

=begin
================================================================
	建立数据库连接
=================================================================
=end

logstdout = Logger.new STDERR

class RankUrl		< ActiveRecord::Base; end
class RankLanguage	< ActiveRecord::Base; end
class RankUseragent	< ActiveRecord::Base; end
ActiveRecord::Base.establish_connection $config['realtime_database']
#ActiveRecord::Base.logger = logstdout

class LogServer	    < ActiveRecord::Base 
	self.abstract_class = true
	establish_connection $config['log_database']
end
class DimLocation   < LogServer; end
class DimLanguage   < LogServer; end
class DimBrowser    < LogServer; end
class DimMachine    < LogServer; end
class DimUser	    < LogServer; end
class DimReferer    < LogServer; end
class DimHost	    < LogServer; end
class DimRequesturi < LogServer; end

MD5_PREFIX = 'log-server-md5-prefix'

def get_md5_str *items
	digest = Digest::MD5.new
	digest << MD5_PREFIX
	items.each do |o|
		digest << '-'
		digest << o
	end
	digest.hexdigest
end

def get_language language_id
	dim = DimLanguage.find language_id, :select=>'pri,sub'
	return "#{dim.pri}-#{dim.sub}" if dim
	'(not set)'
end

def get_browser browser_id
	dim = DimBrowser.find browser_id, :select=>'mobile,platform,browser'
	return [dim.mobile,dim.platform,dim.browser] if dim
	[false, '(not set)', '(not set)']
end

def get_machine_id token, hardware
	md5_str = get_md5_str token, hardware
	dim = DimMachine.find_by_md5 md5_str, :select=>'id'
	return dim.id if dim
	return 0
end

def get_requesturi uri_id
	dim = DimRequesturi.find uri_id, :select=>'request_uri'
	return dim.request_uri if dim
	'null'
end

def get_line_chart step,count,token,hardware
	machine_id = get_machine_id token,hardware
	return '[]' if machine_id == 0

	start_time = Time.now - step.to_i * count.to_i * 3600

	dbres = RankUrl.find(:all,
		:select => 'time, count(counter) as counter',
		:conditions => ["machine_id=? and time>?", machine_id, start_time],
		:group => 'time',
		:order => 'time asc'
	)

	result = []
	dbres.each do |o|
		result << [o.time.to_s, o.counter]
	end

	MultiJson.dump result
end

def get_list_chart type,day,count,token,hardware
	machine_id = get_machine_id token,hardware
	return '[]' if machine_id == 0

	start_time = Time.now - day.to_i * 24 * 3600

	sql = {
		:select => 'requesturi_id, count(counter) as counter',
		:conditions => ["machine_id=? and time>?", machine_id, start_time],
		:group => 'requesturi_id',
		:order => 'counter desc',
		:limit => count.to_i
	}

	if type == 'url'
		dbres = RankUrl.find(:all, sql)
	elsif type == 'language'
		sql[:select] = 'language, count(counter) as counter'
		sql[:group] = 'language'
		dbres = RankLanguage.find(:all, sql)
	elsif type == 'browser'
		sql[:select] = 'browser, count(counter) as counter'
		sql[:group] = 'browser'
		dbres = RankUseragent.find(:all, sql)
	elsif type == 'platform'
		sql[:select] = 'platform, count(counter) as counter'
		sql[:group] = 'platform'
		dbres = RankUseragent.find(:all, sql)
	else
		return '[]'
	end

	result = []
	dbres.each do |o|
		if type == 'url'
			result << [get_requesturi(o.requesturi_id), o.counter]
		elsif type == 'language'
			result << [o.language, o.counter]
		elsif type == 'browser'
			result << [o.browser, o.counter]
		elsif type == 'platform'
			result << [o.platform, o.counter]
		end
	end
	MultiJson.dump result
end

def get_pie_chart type,day,piece,token,hardware
	machine_id = get_machine_id token,hardware
	day = day.to_i
	piece = piece.to_i

	return '[]' if machine_id == 0
	return '[]' if piece < 1
	return '[]' if day < 1

	start_time = Time.now - day * 24 * 3600

	sql = {
		:select => 'mobile, count(counter) as counter',
		:conditions => ["machine_id=? and time>?", machine_id, start_time],
		:group => 'mobile',
		:order => 'counter desc',
	}

	if type == 'mobile'
		dbres = RankUseragent.find(:all, sql)
	elsif type == 'language'
		sql[:select] = 'language, count(counter) as counter'
		sql[:group] = 'language'
		dbres = RankLanguage.find(:all, sql)
	elsif type == 'browser'
		sql[:select] = 'browser, count(counter) as counter'
		sql[:group] = 'browser'
		dbres = RankUseragent.find(:all, sql)
	elsif type == 'platform'
		sql[:select] = 'platform, count(counter) as counter'
		sql[:group] = 'platform'
		dbres = RankUseragent.find(:all, sql)
	else
		return '[]'
	end

	result = []
	others = {'other'=>0}
	item_count = 0
	max_count = piece
	total_count = 0

	dbres.each do |o|
		item_count += 1
		total_count += o.counter

		if item_count >= max_count
			others['other'] += o.counter
		else
			if type == 'mobile'
				key = o.mobile.to_s
			elsif type == 'language'
				key = o.language.to_s
			elsif type == 'browser'
				key = o.browser.to_s
			elsif type == 'platform'
				key = o.platform.to_s
			else
				key = 'other'
			end

			result << [key, o.counter]
		end
	end

	if others['other'] > 0
		result << ['other', others['other']]
	end

	result.map! do |o|
		value = (o[1].to_f / total_count.to_f * 100.0)
		o << sprintf("%2.1f\%", value)
	end

	if type == 'mobile'
		if result.length == 1
			if result[0][0] == 'false'
				result << ['true',0,'0.0%']
			else
				result << ['false',0,'0.0%']
			end
		end

		result.map! do |o|
			if o[0] == 'true'
				o[0] = 'mobile'
			else
				o[0] = 'not-mobile'
			end
			o
		end
	end

	MultiJson.dump result
end

=begin 
=================================================================
	sinatra
=================================================================
=end

#配置服务器
set :bind, host
set :port, port
set :root, File.dirname(__FILE__)
set :app_file, __FILE__
#set :sessions, true
#set :public_folder, Proc.new { File.join(root, "static") }
#set :views, Proc.new { File.join(root, "templates") }
set :environment, :production

get '/api/line/:step/:count/:token/:hardware' do
	get_line_chart  params[:step],params[:count],params[:token],params[:hardware]
end
get '/api/list/:type/:day/:count/:token/:hardware' do
	get_list_chart params[:type],params[:day],params[:count],params[:token],params[:hardware]
end

get '/api/pie/:type/:day/:piece/:token/:hardware' do
	get_pie_chart params[:type],params[:day],params[:piece],params[:token],params[:hardware]
end

not_found do
	'deny' 
end

error do
	'error'
end
