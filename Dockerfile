FROM php:5.6-apache

ENV MAJOR_VERSION 6.5
ENV MINOR_VERSION 21
ENV SOURCEFORGE_MIRROR http://downloads.sourceforge.net
ENV WWW_FOLDER /var/www/html

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y libcurl4-gnutls-dev libpng-dev unzip cron re2c php5-imap python

RUN docker-php-ext-install mysql curl gd zip mbstring
#	apt-get install -y php5-mysql php5-imap php5-curl php5-gd curl unzip cron

WORKDIR /tmp

RUN curl -L -O "${SOURCEFORGE_MIRROR}/project/sugarcrm/1%20-%20SugarCRM%20${MAJOR_VERSION}.X/SugarCommunityEdition-${MAJOR_VERSION}.X/SugarCE-${MAJOR_VERSION}.${MINOR_VERSION}.zip" && \
	unzip SugarCE-${MAJOR_VERSION}.${MINOR_VERSION}.zip && \
	rm -rf ${WWW_FOLDER}/* && \
	cp -R /tmp/SugarCE-Full-${MAJOR_VERSION}.${MINOR_VERSION}/* ${WWW_FOLDER}/ && \
	chown -R www-data:www-data ${WWW_FOLDER}/* && \
	chown -R www-data:www-data ${WWW_FOLDER}

# disable error when adding fields as seen in http://stackoverflow.com/a/20958542
RUN echo "display_errors = Off" >> $PHP_INI_DIR/php.ini
# change upload file size
RUN echo "upload_max_filesize = 10M" >> $PHP_INI_DIR/php.ini

ADD config_override.php.pyt /usr/local/src/config_override.php.pyt
ADD envtemplate.py /usr/local/bin/envtemplate.py
ADD init.sh /usr/local/bin/init.sh

RUN chmod u+x /usr/local/bin/init.sh

ADD crons.conf /root/crons.conf
RUN crontab /root/crons.conf

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/init.sh"]
