![Regress](https://github.com/KyomaHooin/Kanesh/raw/master/regress/regress_screen.png "screenshot")

DESCRIPTION

Correlation coefficient and linear regression plot from CSV output.  

INSTALL
<pre>
apt-get install python-numpy python-scipy python-matplotlib libapache2-mod-wsgi
</pre>
CONFIG
<pre>
/etc/fstab:

tmpfs	/var/www/regress/ram	tmpfs	nodev,nosuid,size=2M	0	0

/etc/apache2/sites-enabled/default-ssl.conf:

&lt;Directory /var/www/media&gt;
    Options -Indexes -Multiviews
    Order allow,deny
    Allow from all
&lt;/Directory&gt;

WSGIScriptAlias /regress /var/www/regress/regress.wsgi
WSGIApplicationGroup %{GLOBAL}
</pre>
INPUT
<pre>
J464B;Na;0.0201335908;0.0201335908;0.0201335908;0.0201335908
J464B;Mg;3.9191309186;3.9398827464;4.0928533632;5.0005976047
J464B;Al;6.008699247;5.5575518959;5.2356014767;4.2395348077
....
</pre>
FILE
<pre>
  web/regress.wsgi - WSGI frontend.

        regress.py - Stand-alone iteration.
regress_screen.png - Output screenshot.
</pre>

CONTACT

Author: richard.bruna@protonmail.com<br>
Source: https://github.com/KyomaHooin/Kanesh

