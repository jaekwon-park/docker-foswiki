FROM ubuntu:16.04

MAINTAINER Jaekwon Park <jaekwon.park@code-post.com>

# Configure apt
RUN LC_ALL=C.UTF-8 
RUN apt-get -y update && C_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apache2 rcs wget \
    libdbd-mysql-perl  libapache2-request-perl  libfcgi-perl libfcgi-procmanager-perl \
    perl-modules-5.22 libalgorithm-diff-perl libauthen-sasl-perl libcgi-pm-perl libcgi-session-perl libcrypt-passwdmd5-perl libdigest-sha-perl libemail-mime-perl libencode-perl liberror-perl libfile-copy-recursive-perl libhtml-parser-perl libhtml-tree-perl libio-socket-ip-perl libio-socket-ssl-perl libjson-perl liblocale-maketext-lexicon-perl liblocale-msgfmt-perl libwww-perl liblwp-protocol-https-perl liburi-perl libversion-perl libnet-ldap-perl && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# Configure apache module
RUN chown -R www-data:www-data /var/www/html/
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork cgid access_compat rewrite && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

RUN wget -O /tmp/Foswiki-2.1.4.tgz https://downloads.sourceforge.net/project/foswiki/foswiki/2.1.4/Foswiki-2.1.4.tgz && \
    tar xvfz /tmp/Foswiki-2.1.4.tgz -C /var/www/html/ && \
    mv /var/www/html/Foswiki-2.1.4/* /var/www/html/ && \
    rm -rf /var/www/html/Foswiki-2.1.4/ && \
    apt-get purge wget && apt-get autoremove 

COPY foswiki.conf /etc/apache2/sites-available/

RUN a2ensite foswiki.conf && \
    a2dissite 000-default.conf

WORKDIR /var/www/html

COPY apache2-foreground /usr/local/bin/
COPY pre-configure /usr/local/bin/

EXPOSE 80
VOLUME /var/www/html/pub
VOLUME /var/www/html/data

RUN  /usr/local/bin/pre-configure

CMD ["apache2-foreground"]
