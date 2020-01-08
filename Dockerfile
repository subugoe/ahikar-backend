MAINTAINER mgoebel <goebel@sub.uni-goettingen.de>

FROM existdb/existdb:release

COPY build/*.xar /exist/autodeploy/

FROM httpd

COPY httpd-reverse-proxy.conf /usr/local/apache2/conf/httpd.conf

# This is the Additional Directory where we are going to keep our Virtualhost configuraiton files
RUN mkdir -p /usr/local/apache2/conf/sites/

EXPOSE 80

# The Base command, This command should be used to start the container
# Remember, A Container is a Process.As long as the base process (started by base cmd) is live the Container will be ALIVE.
CMD ["httpd", "-D", "FOREGROUND"]
