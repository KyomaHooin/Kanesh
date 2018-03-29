![Color](https://github.com/KyomaHooin/Kanesh/raw/master/color/color_screen.png "screenshot")

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
INPUT
<pre>
J459;Moss Grey;40.0;4.7;8.0
J459;Moss Grey;40.2;3.9;7.7
J462;Grey Biege;59.8;13.1;17.0
J462;Grey Biege;57.6;11.2;19.1
</pre>
FILE
<pre>
   web/color.png  - Logo by Colour Developers (c) 2013-2016
   web/color.wsgi - WSGI frontend.

   diagrams.patch - Lab to XYZ plot patch.
 color_screen.png - Web screenshot.
 colour-0.3.8.zip - Colour library by Colour Developers (c) 2013-2016
</pre>

CONTACT

Source: https://github.com/KyomaHooin/Kanesh

