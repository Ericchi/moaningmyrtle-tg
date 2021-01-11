# Moaning Myrtle

A Telegram bot made in Ruby that likes to complain a lot. Training file is not included, since it contains sensitive data. Requires **megahal** and **telegram-bot-ruby**.
The bot requires you to provide a training file or a pre-existing MegaHAL brain file. The training file for MegaHAL should contain sentences that begin with "I complain" or "Brief complaint", but you can personalize it and even create a happy brain that shares joy with the chat instead.
Based on [LucentW's agnellopio-tg](https://github.com/LucentW/agnellopio-tg).

## Installation
1. Install Ruby. [Click here](https://www.ruby-lang.org/en/documentation/installation/) for instructions
2. Install the bot's dependencies:<br />
    `gem install telegram-bot-ruby megahal`
3. Set up the repository: <br />
    `git clone https://gitlab.com/Ericchi/moaningmyrtle-tg/`
4. Contact BotFather on Telegram to create a new bot and get a token and a username for it
5. Rename sample-config.rb into config.rb and put your token, bot username and group ID there.<br />**Tip:** if you don't know your group ID, you can launch the bot later, invite it into the group, send a message and check the terminal.
5. Run `megahal` and train it with a list of complaints (there's a sample complaints.txt file in the repository), then save the brain file as "brain.brn". For more info [click here](https://github.com/kranzky/megahal)

## Running the bot
### Linux
Run start.sh (`sh start.sh`) or use the **screen** command if you don't want to have the terminal occupied by the bot:<br />
`screen -S moaningmyrtle -d -m sh start.sh`
### Mac OS
Same as Linux
### Windows
Launch your Ruby execution environment or your Windows subsystem for Linux, navigate to the bot's directory and execute it with `sh start.sh`