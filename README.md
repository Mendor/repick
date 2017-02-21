# Repick

Telegram bot to re-upload inline sent images to
[Pomf](https://github.com/pomf/pomf)-compatible image hosting services. Just
forward Telegram message with inline picture to it privately.

The code is really shitty and I'm not sure would I actively modify it further.
Now it does what it should, so.

Should work with any of clones of [this list](https://docs.google.com/spreadsheets/d/1kh1TZdtyX7UlRd55OBxf7DB-JGj2rsfWckI0FPQRYhE/edit#gid=0),
tested with several of them.

Can be run as Docker container, otherwise require Elixir 1.3 or newer to be
compiled.


## Required preparations

1. Access @BotFather to register a new Telegram bot. Write down its API token.
2. Copy `config.yml.sample` to `config.yml`, update it with your Telegram bot
   token and desired Pomf clone URLs (don't forget about trailing / in
   `pomf_download_url` paramter).


## Compiling and running

#### Stand-alone

    $ mix deps.get
    $ mix compile
    $ mix run --no-halt

#### With Docker

    $ sudo docker build -t repick .
    $ sudo docker run -d repick


## License

[MIT](https://opensource.org/licenses/MIT)
