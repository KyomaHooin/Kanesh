![Color](https://github.com/KyomaHooin/Sumerian/raw/master/color/color_screen.png "screenshot")

DESCRIPTION

Spectra graph/data generator from QCREPORT CSV output.  

INSTALL
<pre>
apt-get install python-numpy python-scipy python-matplotlib libapache2-mod-wsgi
</pre>
CONFIG
<pre>
/etc/apache2/sites-enabled/default-ssl.conf:

&lt;Directory /var/www/media&gt;
    Options -Indexes -Multiviews
    Order allow,deny
    Allow from all
&lt;/Directory&gt;

WSGIScriptAlias /color /var/www/color/color.wsgi
WSGIApplicationGroup %{GLOBAL}
</pre>
FILE
<pre>
   web/color.png  - Logo by Colour Developers (c) 2013-2016
   web/color.wsgi - WSGI frontend.

      diagrams.py - Modified library.
 color_screen.png - Web screenshot.
 colour-0.3.8.zip - Colour library by Colour Developers (c) 2013-2016
</pre>

CONTACT

Author: richard_bruna@nm.cz<br>
Source: https://github.com/KyomaHooin/Sumerian

