log-analytics
=============

Log analytics like google analytics, but more simple.

安装配置mysql

	mysql -uroot -p
	create database log_server
	GRANT ALL PRIVILEGES ON log_server.* TO log_admin@localhost IDENTIFIED BY 'log_admin_pass' WITH GRANT OPTION;


安装ruby模块
	gem install active_record
	gem install em-zeromq
	gem install specific_install
	gem specific_install -l git://github.com/nateklaiber/accept_language.git
	gem install useragent
	gem install geoip
