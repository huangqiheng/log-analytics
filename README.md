# log-analytics
=============

Log analytics like google analytics, but more simple.

## 安装依赖环境

``` sh
apt-get update
apt-get install build-essential libxslt1.1 libxslt1-dev libxml2 ruby-full libssl-dev libopenssl-ruby libcurl4-openssl-dev git-core libreadline5-dev
apt-get install mysql-server libmysqlclient-dev libmysql-ruby 

gem install bundle rake
```

## 下载配置和安装运行

``` sh
git clone https://github.com/huangqiheng/log-analytics.git
cd log-analytics
```

需要配置3个服务器的yml配置文件
打开以下文件，修正里面的监听设置和数据库配置：
* log-server.yml
* realtime-server.yml
* api-server.yml

然后安装运行：
``` sh
bundle install
rake db:create
rake start 	#单机运行3个服务器
```

如果提示找不到accept-language，那是安装不成功，可单独安装
```sh
gem install specific_install
gem specific_install -l git://github.com/nateklaiber/accept_language.git

```

## 测试是否正常运行

``` sh
rake testcli	#持续塞入测试数据，有了些数据了，api接口才有东西看

curl http://localhost:2102/api/line/2/24/token-id-001/machine-id-1
curl http://localhost:2102/api/list/url/7/10/token-id-001/machine-id-1
curl http://localhost:2102/api/pie/browser/7/10/token-id-001/machine-id-1

rake db:reset	#清空测试数据
```

## 日常维护服务器

看看支持怎么样的维护操作？
``` sh
rake  --tasks

rake build           # Build log-analytics-0.0.1.gem into the pkg directory
rake db:create       # 创建数据库和用户
rake db:destroy      # 销毁数据库和用户
rake db:reset        # 清空数据库，相当于从置程序
rake install         # Build and install log-analytics-0.0.1.gem into system gems
rake release         # Create tag v0.0.1 and build and push log-analytics-0.0.1.gem to Rubygems
rake start           # 同rake start:all
rake start:all       # 启动以下服务器：log服务器，realtime服务器，api服务器
rake start:api       # 启动api接口服务器
rake start:log       # 启动log日志服务器
rake start:realtime  # 启动realtime实时分析服务器
rake stop            # 同rake stop:all
rake stop:all        # 关闭以下服务器：log服务器，realtime服务器，api服务器
rake stop:api        # 关闭api服务器
rake stop:log        # 关闭log服务器
rake stop:realtime   # 关闭realtime服务器
rake testcli         # 运行模拟测试的客户端，持续塞入模拟数据
```

log-server, realtime-server, api-server可以分别运行在不同的主机上
只需配置好相应的yml配置文件即可

单独运行指定的服务器：
``` sh
rake start:log
rake start:realtime
rake start:api
```

或单独关闭指定的服务器：
``` sh
rake stop:log
rake stop:realtime
rake stop:api
```

或关闭全部服务器：
``` sh
rake stop
```
## 以后的开发计划

* mysql配置主从架构，提高数据库的读取服务能力
* api-server增加redis缓存，大大减少对mysql的访问
* log-server前置zeromq分发路由，成为负载均衡模式，解决入库瓶颈

