FROM ubuntu:16.04


# Base
RUN apt-get update
RUN apt-get install --yes \
		ca-certificates make git gcc libconfig-dev libevent-dev libjansson-dev libreadline-dev libssl-dev  \
		xvfb wkhtmltopdf gnupg\
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


RUN git clone --recursive https://github.com/vysheng/tg.git "$TG_HOME" \
    && (    cd $TG_HOME && git checkout 160231bdd7887316b544412e8b97bcdd86ac25a4 \
        &&  cd tgl && git checkout 08b6340c1cbf1ef59690007b0207de9d5c904c07 \
        &&  cd tl-parser && git checkout 1659d87b8dfee385cc587661d592a5ade2b4171b \
        )
WORKDIR "$TG_HOME"
RUN ./configure --disable-liblua --disable-python && make
COPY extra/weather.sh "$WEATHER_DIR"/weather.sh

RUN chmod +x "$WEATHER_DIR"/weather.sh

COPY extra/auth.bot.gpg $CLI_DATA/

RUN gpg --yes --batch --passphrase=$GPG_PASS $CLI_DATA/auth.bot.gpg -o $CLI_DATA/auth

CMD ["bash"]

ENTRYPOINT ["/root/weather/weather.sh"]
