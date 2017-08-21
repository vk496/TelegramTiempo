FROM ubuntu:16.04


# Base
RUN apt-get update
RUN apt-get install --yes \
		ca-certificates make git gcc libconfig-dev libevent-dev libjansson-dev libreadline-dev libssl-dev  \
		xvfb wkhtmltopdf gnupg xmlstarlet curl\
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists \
  && echo "[http]\n\tsslVerify = true\n\tslCAinfo = /etc/ssl/certs/ca-certificates.crt\n" >> ~/.gitconfig
  # the install ca-certificates and adding "slCAinfo = /etc/ssl/certs/ca-certificates.crt" to .gitconfig
  # fixed tg cloning via git with the error:
  ## fatal: unable to access 'https://github.com/vysheng/tg.git/': Problem with the SSL CA cert (path? access rights?)



#ENV TG_USER telegram
ENV HOME /root
ENV TG_HOME "$HOME"/tg
ENV COMMAND python
ENV WEATHER_DIR "$HOME"/weather
ENV TG_CLI "$TG_HOME"/bin/telegram-cli
ENV TG_PUBKEY "$TG_HOME"/tg/tg-server.pub
ENV CLI_DATA "$HOME"/.telegram-cli


ENV PATH "$TG_HOME"/tg/bin/:$PATH


RUN mkdir -p "$TG_HOME" "$WEATHER_DIR"


# RUN git clone --recursive https://github.com/and-rom/tg.git "$TG_HOME" \
#     && (    cd $TG_HOME && git checkout f2c95efab41f1ade33c9b11de1cf2618ee7699d3 \
#         &&  cd tgl && git checkout 2634b2edf3637301578428315915ff992e9b210a \
#         &&  cd tl-parser && git checkout 36bf1902ff3476c75d0b1f42b34a91e944123b3c \
#         )
    
RUN git clone --depth 1 https://github.com/and-rom/tg.git "$TG_HOME" \
    && (    cd $TG_HOME && git clone --depth 1 -b dev-1.4.0 https://github.com/majn/tgl )
#         &&  cd tgl && git checkout 2634b2edf3637301578428315915ff992e9b210a \
#         &&  cd tl-parser && git checkout 36bf1902ff3476c75d0b1f42b34a91e944123b3c \
#         )

WORKDIR "$TG_HOME"
RUN ./configure --disable-liblua --disable-python && make -j5
COPY extra/weather.sh "$WEATHER_DIR"/weather.sh
COPY extra/weatherv2.sh "$WEATHER_DIR"/weatherv2.sh

RUN chmod +x "$WEATHER_DIR"/weather.sh
RUN chmod +x "$WEATHER_DIR"/weatherv2.sh

COPY extra/auth.bot.gpg $CLI_DATA/

CMD ["bash"]

ENTRYPOINT ["/root/weather/weather.sh"]
