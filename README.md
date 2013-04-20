jqRealtime
==========

And erlang realtime http server (mysql, mochiweb, jQuery)
This project is **open-source (GNU AGPL)**, so you can use it freely.

How to Install ?
------------

- Install Erlang OTP on your computer (download a version from http://www.erlang.org/), like R16B.

- Compile and install Erlang OTP :

```bash
wget http://www.erlang.org/download/otp_src_R16B.tar.gz
tar -zxpvf otp_src_R16B.tar.gz
cd otp_src_R16B
./configure
```

- At this step (./configure), check if all dependencies are satisfied, then make & make install erlang :

```bash
make
make install
```

- Now erlang should be located in /usr/bin/local, you can open the erlang console by typing in your shell :

```bash
erl
```
  
- Set up the database (you'll find the SQL schema at docs/schema.sql)

- Configure the database credentials in src/jqrealtime_web.erl :

```bash
%% MySQL Configuration
-define(MYSQL_SERVER, "localhost").
-define(MYSQL_USER, "root").
-define(MYSQL_PASSWD, "").
-define(MYSQL_TABLE, "jqrealtime").
-define(MYSQL_PORT, 3306).
```

- Now make jqRealtime :

```bash
make
  ==> jqrealtime (get-deps)
  Pulling mochiweb from {git,"git://github.com/mochi/mochiweb.git",
                             {branch,"master"}}
  Cloning into 'mochiweb'...
  Pulling emysql from {git,"git://github.com/Eonblast/Emysql.git",
                           {branch,"master"}}
  Cloning into 'emysql'...
  ==> mochiweb (get-deps)
  ==> emysql (get-deps)
  ...
  ... etc
```

- You can now start the webserver with start-dev.sh (or use start-daemon.sh to detach it from console)

```bash
./start-dev.sh
```

- Your webserver is at http://localhost:8080/, but you can configure the port or the IP in src/jqrealtime_sup.erl

