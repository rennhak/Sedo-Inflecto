                                    SEDO INFLECTO
                              Version esyscmd( `git describe --tags' )



WHAT IS THE SEDO INFLECTO PROJECT ?

The Sedo [1] Inflecto [2] project explores various smoothing functions [3] in multi-dimensions. Its purpose is
to help understand various smoothing algorithms and how they are implemented as well as being a library to handle
smoothing tasks.

[1] "Smooth" in Latin, http://www.latinwordlist.com/latin-word-for/latin-word-for-smooth-76362857.htm 
[2] "Curve" in Latin, http://www.latinwordlist.com/latin-word-for/latin-word-for-curve-38591454.htm
[3] http://en.wikipedia.org/wiki/Smoothing

`FEATURES'
define(FEATURES,esyscmd( `cat m4/FEATURES.in | sed -e "s/#.*//" -e "/^$/d" -e "s/^\*\*/    o /" -e "s/^\*/\n  o /"' ))
FEATURES

ON WHAT HARDWARE DOES IT RUN?

    This Software was originally developed and tested on 32-bit x86 / SMP based PCs running on
    Ubuntu and Gentoo GNU/Linux 2.6.x. Other direct Linux and Unix derivates should be viable too as
    long as all dynamical linking dependencys are met. 


DOCUMENTATION


    A general developers API guide can be extracted from the Doxygen
    subdirectory which is able to generate HTML as well as PDF docs. Please refer to the
    [Rake|Make]file for additional information how to generate this documentation.


INSTALLING

    If you got this package as a packed tar.gz or tar.bz2 please unpack the contents in
    an appropriate folder e.g. ~/jokemachine/ and follow the supplied INSTALL or README
    documentation. Please delete or replace existing versions before unpacking/installing
    new ones.


SOFTWARE REQUIREMENTS

    This package was developed and compiled under Gentoo GNU/Linux 2.6.x with the Ruby 2.x 
    interpreter.


BUILD PROCESS

CONFIGURING

COMPILING

RUNNING

IF SOMETHING GOES WRONG

    In case you enconter bugs which seem to be related to the JOKESMACHINE package please check in
    the MAINTAINERS file for the associated person in charge and contact him or her directly. If
    there is no valid address then try to mail Bjoern Rennhak <bjoern AT rennhak DOT com> to get
    some basic assistance in finding the right person in charge of this section of the JOKESMACHINE
    project.


NOTES

    This README file was last modified on the $LastChangedDate$
    by $LastChangedBy$. Current file version is $Rev$ (which is a minor revision number) .


COPYRIGHT

    Please refer to the COPYRIGHT file in the various folders for explicit copyright notice.  Unless
    otherwise stated all remains protected and copyrighted by Bjoern Rennhak <bjoern AT rennhak DOT
    com>.


# vim:ts=2:tw=100:wm=100
