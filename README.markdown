# Reading List to Pocket

## Intro
I curate a lot of what I read. And I read a lot. [Pocket](http://www.getpocket.com) is perfect for this. I used to use Instapaper, but Pocket is even better: it allows me to tag as I add, and has better integration into things like Hootsuite.

However, sometimes I find myself somewhere with no wifi (a plane, the boonies, our office bathroom, etc.) with a few dozen open tabs and no way of getting them into Pocket.

I found a great article by [Ryan Toohill](http://blog.ryantoohil.com/2012/03/using-safaris-reading-list-to-feed-instapaper.php) where he wrote a background task for syncing Reading List to Instapaper. This is a fork of his code that does this for Pocket.

## Setup

As this app is just a hack, be ready for a bit of effort.

### RVM

Nokogiri 1.6 dropped support for Ruby 1.8.x and so we have to use 1.9 or 2.0, i.e. the version of Ruby that comes with OSX won't do. This app was developed using 1.9.3 and is running fine with 1.9.2, so we'll go for 1.9.2 in the setup instructions.

If you have no idea what I'm talking about you should probably stop right now. Otherwise, you will need to install RVM & a 1.9 version of Ruby, create a gemset for our app, and then install a few gems. Here's a check list:

* [How to Install RVM](https://rvm.io/rvm/install)
* Install the appropriate version of Ruby: `rvm install 1.9.2`
* Create your gemset: `rvm gemset create pocket`
* Install bundler: `gem install bundler`
* Install your gems: `bundle install`
* Check it all works: `ruby -v`

### Get an access token from Pocket

Pocket uses [OAuth2](http://aaronparecki.com/articles/2012/07/29/1/oauth2-simplified) in an implementation with a lot of custom names that made it fiddly to work with any OAuth gems and the command line. To save time, I built a nasty hack. It's a PITA, I wish Pocket supported the 'password' grant type in their implementation of Oauth but they don't, so we have to do it this way instead.

* Open the file `1.html`. It should download a file called `request` and then redirect you to `2.html`
* The `request` file should contain a single line that looks like this:

    `code=43848dae-f000-1bd2-e434-454997`

* Take the string after the equals sign (in this case `43848dae-f000-1bd2-e434-454997`), cut/paste it into the box on the page `2.html` (which should already be open) and press Submit.
* If successful, you should be redirected to the Google home page.
* Now open the last file, `3.html`, copy the code into the box and press submit.
* This will take you to the Pocket website (login if necessary) and ask you to authorize access. (If it doesn't, it usually means you've already provided access.)
* When you say yes, it will download another file, this time called `authorize` which looks like this:

    `access_token=aaaaaaaa-bbbb-cccc-dddd-eeeeee&username=jon-doe`

* Take the string after the equals sign and before the `&` character (in this case `aaaaaaaa-bbbb-cccc-dddd-eeeeee`). This is your access token.

### Installation

By now you should have a working copy of RVM and an access token. We're ready to install.

* Clone the repo to somewhere you're comfortable with it. I put mine in `/usr/local/pocket`. NOTE: If you do this you may have to prefix some of the commands below with `sudo`
* Open up terminal and cd to the folder you chose
* Make the script executable: `chmod +x readinglist_to_pocket.rb`
* Find out where RVM put your ruby, as follows:
    * `rvm use 1.9.2@pocket`
    * `which ruby`
* Open `readinglist_to_pocket.rb` using your favorite editor
* Change `USER_FOLDER/.rvm/bin/rvm 1.9.2` in the first line to match the output of which ruby.
* If you used a different name for your gemset, change the `@pocket` after as well.
* A few lines further down you'll see `my_pocket_access_key = 'aaaaaaaa-bbbb-cccc-dddd-eeeeee'` Change the number to match the Access Token you obtained earlier (see above).
* If you want your imported articles to be tagged differently, change the line `my_pocket_tags = 'safari'` to a comma separated list of tags. Avoid spaces, it causes problems.
* Save the file `readinglist_to_pocket.rb`
* Open the file `com.ryantoohil.readinglisttopocket.plist`
* Change the line with `INSTALLATION_FOLDER` in it to be wherever you put your repo (in my case this is `/usr/local/pocket/`)
* Change the line with `USER_FOLDER` to be your home path (in my case `/Users/mellis/`)
* Save the file `com.ryantoohil.readinglisttopocket.plist`
* Now run the command `launchctl load com.ryantoohil.readinglisttopocket.plist`

At this point, if you've got anything in your Reading List it should sync with Pocket. Otherwise, go to Safari and add something and you should see a notification in the system toolbar (assuming you're running on OSX 10.8 or later).

## Revisions
* July 9, 2013: Ported to use Pocket instead of Instapaper
* May 6, 2012: Removed rails dependency and cleaned up DateTime usage. I think.
* Mar 31, 2012: Initial Commit
