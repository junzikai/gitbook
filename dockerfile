FROM mhart/alpine-node:6

#use aliyun and dns
RUN sed -i s/dl-cdn\.alpinelinux\.org/mirrors.aliyun.com/g /etc/apk/repositories && \
apk update && apk add --no-cache openssh-client git curl
#use no StrictHostKeyChecking
RUN sed -i '/StrictHostKey/ {s/#//;s/ask/no/}' /etc/ssh/ssh_config

WORKDIR /root
EXPOSE 4000 35729
ENV PROJECT=/root/project

#install gitbook
RUN npm install --global gitbook-cli && \
gitbook fetch && \
npm cache clear &&\
rm -rf /tmp/* && \
#install plugins
echo -e "{\n\
    \"plugins\": [\"-lunr\", \"-search\", \"search-plus\",\"toggle-chapters\",\"splitter\",\"ace\",\"edit-link\"],\n\
    \"pluginsConfig\": {\n\
        \"edit-link\": {\n\
            \"base\": \"GIT_HUB\",\n\
            \"label\": \"Edit This Page\"\n\
         }\n\
     }\n\
}" > book.json && \
gitbook install && \
version=$(gitbook -V | grep GitBook | awk -F: '{print $2}' | sed 's/\s//') && \
mv /root/node_modules/* /root/.gitbook/versions/${version}/node_modules/ && \
rm -rf /root/node_modules
#VOLUME /root/project
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD curl -fs http://localhost:4000 || exit 1
COPY startup.sh /root/startup.sh
CMD [ "sh","/root/startup.sh" ]
