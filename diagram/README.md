![Diagram](https://github.com/KyomaHooin/Kanesh/raw/master/diagram/diagram_screen.png "screenshot")

DESCRIPTION

Write ternary diagram plot from CSV data.

INSTALL
<pre>
PYTHON

apt-get install python-numpy python-scipy python-matplotlib libapache2-mod-wsgi
</pre>
INPUT
<pre>
sep=;
ID;Num(Excl);Na;Na;Mg;Mg;Al; .. ;Si;P;P;K;K;Ca;Ca;Ti;Ti;Mn;Mn;Fe;Fe;
;;(avg);(sd);(avg);(sd);(avg .. ;(avg);(sd);(avg);(sd);(avg);(sd);
J429;24(22);0,02;0,025;7,62; .. ;0,33;0,032;0,1;0,055;4,2;0,369;Moss Grey
J430;24(22);0,02;0,021;6,63; .. ;0,038;0,12;0,038;3,94;0,379;Grey Beige
J431;24(22);0,11;0,176;6,94; .. ;0,055;0,1;0,024;4,05;0,539;Grey Beige
</pre>
FILE
<pre>
  web/python-powerd.png - Python logo by Python.org
       web/diagram.wsgi - WSGI frontend.

              diagram.r - Original R program.
             diagram.py - Standalone Python program.
ternary_axes_subplot.py - Corner label patch by ZGainsforth (c) 2016
     diagram_screen.png - Output sreen.
     python-ternary.zip - Ternary diagram library by Marc Harper (c) 2015 MIT
</pre>
CONTACT

Author: richard_bruna@nm.cz<br>
Source: https://github.com/KyomaHooin/Kanesh

