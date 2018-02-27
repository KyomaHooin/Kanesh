DESCRIPTION

Parse X-Rite QC-Report colorimetr CSV data export into preformated XLSX.

INSTALL
<pre>
apt-get install python-openpyxl libapache2-mod-wsgi
</pre>
CONFIG
<pre>
/etc/apache2/sites-enabled/default-ssl.conf:

&lt;Directory /var/www/media&gt;
    Options -Indexes -Multiviews
    Order allow,deny
    Allow from all
&lt;/Directory&gt;

WSGIScriptAlias /xrite /var/www/xrite/xrite.wsgi
WSGIApplicationGroup %{GLOBAL}
</pre>
INPUT
<pre>
REPORT DATE,REPORT TIME,DEVICE S/N,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
14.08.2017,10:08:21,2010004248,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
ACTIVE TOLLERANCE,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
TOLERANCE TYPE/ILLUMINANT/OBSERVER,LIMIT,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
....
</pre>
FILE
<pre>
xrite.wsgi - WSGI frontend.
</pre>

CONTACT

Author: richard.bruna@protonmail.com<br>
Source: https://github.com/KyomaHooin/Kanesh

