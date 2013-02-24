log-analytics
=============

Log analytics like google analytics, but more simple.

安装配置mysql

	mysql -uroot -p

	#---创建原始日志数据库---
	create database log_server

	#创建日志入库账户
	GRANT ALL PRIVILEGES ON log_server.* TO log_admin@localhost IDENTIFIED BY 'log_admin_pass';

	#创建只读账户
	GRANT SELECT ON log_server.* TO readlog@localhost IDENTIFIED BY 'readlogpass';
	GRANT SELECT ON log_server.* TO readlog@'%' IDENTIFIED BY 'readlogpass';

	#---创建实时聚合数据库---
	create database realtime_server

	#创建维护realtime数据库的账户
	GRANT ALL PRIVILEGES ON realtime_server.* TO realtime_admin@localhost IDENTIFIED BY 'realtime_admin_pass';
	
	#创建只读账户
	GRANT SELECT ON realtime_server.* TO readrank@localhost IDENTIFIED BY 'readlogpass';
	GRANT SELECT ON realtime_server.* TO readrank@'%' IDENTIFIED BY 'readlogpass';


安装ruby模块

	gem install active_record
	gem install em-zeromq
	gem install specific_install
	gem specific_install -l git://github.com/nateklaiber/accept_language.git
	gem install useragent
	gem install geoip
	gem install sinatra
	gem install thin

