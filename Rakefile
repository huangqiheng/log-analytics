#encoding: utf-8
require "bundler/gem_tasks"
require 'yaml'
require 'mysql2'
require 'highline/import'

namespace :start do

	desc '启动log日志服务器'
	task :log do
		system 'ruby $PWD/log-server.rb &'
	end

	desc '启动realtime实时分析服务器'
	task :realtime do
		system 'ruby $PWD/realtime-server.rb &'
	end

	desc '启动api接口服务器'
	task :api do
		system 'ruby $PWD/api-server.rb &'
	end

	desc '启动以下服务器：log服务器，realtime服务器，api服务器'
	task :all => [:log, :realtime, :api]
end

desc '同rake start:all'
task :start do
	Rake::Task['start:all'].invoke
end

namespace :stop do

	desc '关闭log服务器'
	task :log do
		system "ps aux | awk \'\/log-server.rb/{print $2}\' | xargs kill -9"
	end

	desc '关闭realtime服务器'
	task :realtime do
		system "ps aux | awk \'\/realtime-server.rb/{print $2}\' | xargs kill -9"
	end

	desc '关闭api服务器'
	task :api do
		system "ps aux | awk \'\/api-server.rb/{print $2}\' | xargs kill -9"
	end

	desc '关闭以下服务器：log服务器，realtime服务器，api服务器'
	task :all => [:log, :realtime, :api]
end

desc '同rake stop:all'
task :stop do
	Rake::Task['stop:all'].invoke
end

desc '运行模拟测试的客户端，持续塞入模拟数据'
task :testcli do
	system 'ruby $PWD/test-cli.rb'
end

namespace :db do
	desc '创建数据库和用户'
	task :create do
		log_config = YAML.load_file 'log-server.yml'
		realtime_config = YAML.load_file 'realtime-server.yml'
		api_config = YAML.load_file 'api-server.yml'

		log_admin = log_config['database']
		realtime_admin = realtime_config['realtime_database']
		log_realonly = api_config['log_database']
		realtime_realonly = api_config['realtime_database']

		login_pass = ask('请输入log-server的mysql的root密码：') {|q| q.echo = false}

		login_pass_rt = ''
		same_db = (log_admin['host'] == realtime_admin['host'])

		if not same_db
			login_pass_rt = ask('请输入realtime-server的mysql的root密码[相同则直接回车]：') {|q| q.echo = false}
		end

		if login_pass_rt.strip == ''
			login_pass_rt = login_pass
		end

		client = Mysql2::Client.new(:host=>log_admin['host'], :username=>'root', :password=>login_pass)

		db_name = log_admin['database']
		db_user = log_admin['username']
		db_pass = log_admin['password']
		db_name_r = log_realonly['database']
		db_user_r = log_realonly['username']
		db_pass_r = log_realonly['password']

		client.query("CREATE DATABASE #{db_name} CHARACTER SET utf8")
		client.query("GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user}@localhost IDENTIFIED BY \'#{db_pass}\'")
		client.query("GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user}@\'%\'IDENTIFIED BY \'#{db_pass}\'")
		client.query("GRANT SELECT ON #{db_name_r}.* TO #{db_user_r}@localhost IDENTIFIED BY \'#{db_pass_r}\'")
		client.query("GRANT SELECT ON #{db_name_r}.* TO #{db_user_r}@\'%\' IDENTIFIED BY \'#{db_pass_r}\'")

		if not same_db
			client.query("FLUSH PRIVILEGES")
			client.close
			client = Mysql2::Client.new(:host=>realtime_admin['host'], :username=>'root', :password=>login_pass_rt)
		end

		db_name = realtime_admin['database']
		db_user = realtime_admin['username']
		db_pass = realtime_admin['password']
		db_name_r = realtime_realonly['database']
		db_user_r = realtime_realonly['username']
		db_pass_r = realtime_realonly['password']


		client.query("CREATE DATABASE #{db_name} CHARACTER SET utf8")
		client.query("GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user}@localhost IDENTIFIED BY \'#{db_pass}\'")
		client.query("GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user}@\'%\'IDENTIFIED BY \'#{db_pass}\'")
		client.query("GRANT SELECT ON #{db_name_r}.* TO #{db_user_r}@localhost IDENTIFIED BY \'#{db_pass_r}\'")
		client.query("GRANT SELECT ON #{db_name_r}.* TO #{db_user_r}@\'%\' IDENTIFIED BY \'#{db_pass_r}\'")
		client.query("FLUSH PRIVILEGES")
		client.close
	end

	desc '销毁数据库和用户'
	task :destroy do
		log_config = YAML.load_file 'log-server.yml'
		realtime_config = YAML.load_file 'realtime-server.yml'
		api_config = YAML.load_file 'api-server.yml'

		log_admin = log_config['database']
		realtime_admin = realtime_config['realtime_database']
		log_realonly = api_config['log_database']
		realtime_realonly = api_config['realtime_database']

		login_pass = ask('请输入log-server的mysql的root密码：') {|q| q.echo = false}

		login_pass_rt = ''
		same_db = (log_admin['host'] == realtime_admin['host'])

		if not same_db
			login_pass_rt = ask('请输入realtime-server的mysql的root密码[相同则直接回车]：') {|q| q.echo = false}
		end

		if login_pass_rt.strip == ''
			login_pass_rt = login_pass
		end

		client = Mysql2::Client.new(:host=>log_admin['host'], :username=>'root', :password=>login_pass)

		db_name = log_admin['database']
		db_user = log_admin['username']
		db_user_r = log_realonly['username']

		client.query("drop database if exists #{db_name}")
		client.query("use mysql")
		client.query("delete from user where user= \'#{db_user}\'")
		client.query("delete from user where user= \'#{db_user_r}\'")

		if not same_db
			client.query("FLUSH PRIVILEGES")
			client.close
			client = Mysql2::Client.new(:host=>realtime_admin['host'], :username=>'root', :password=>login_pass_rt)
		end

		db_name = realtime_admin['database']
		db_user = realtime_admin['username']
		db_user_r = realtime_realonly['username']

		client.query("drop database if exists #{db_name}")
		client.query("use mysql")
		client.query("delete from mysql.user where user= \'#{db_user}\'")
		client.query("delete from mysql.user where user= \'#{db_user_r}\'")
		client.query("FLUSH PRIVILEGES")
		client.close
	end

	desc '清空数据库，相当于从置程序'
	task :reset do
		log_config = YAML.load_file 'log-server.yml'
		log_config = Hash[log_config['database'].map{|(k,v)| [k.to_sym,v]}]
		 
		client = Mysql2::Client.new log_config
		client.query 'drop table if exists fact_requests'
		client.query 'drop table if exists dim_referers'
		client.query 'drop table if exists dim_locations'
		client.query 'drop table if exists dim_languages'
		client.query 'drop table if exists dim_browsers'
		client.query 'drop table if exists dim_machines'
		client.query 'drop table if exists dim_users'
		client.query 'drop table if exists dim_hosts'
		client.query 'drop table if exists dim_requesturis'


		rtm_config = YAML.load_file 'realtime-server.yml'
		rtm_config = Hash[rtm_config['realtime_database'].map{|(k,v)| [k.to_sym,v]}]
		client2 = Mysql2::Client.new rtm_config
		client2.query 'drop table if exists rank_urls'
		client2.query 'drop table if exists rank_languages'
		client2.query 'drop table if exists rank_useragents'

		puts 'reset ok!'
	end
end
