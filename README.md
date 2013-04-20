jqRealtime
==========

And erlang realtime http server (mysql, mochiweb, jQuery)
This project is **open-source (GNU AGPL)**, so you can use it freely.

How to Install ?
------------

- Install Erlang OTP on your computer : http://www.erlang.org/
- Compile and install it :

```bash
wget http://www.erlang.org/download/otp_src_R16B.tar.gz
tar -zxpvf otp_src_R16B.tar.gz
cd otp_src_R16B
./configure
```

- At this point, check if all dependencies are satisfied, then :

```bash
make
make install
```

- Now erlang should be placed in /usr/bin/local, you can open the erlang console by typing :

```bash
erl
```
  
- Set up the database (you'll find the SQL schema at docs/schema.sql)
