# Reading List to Pocket


## Intro
[Pocket](http://www.getpocket.com) I curate a lot of what I read. Pocket is perfect for this. I used to use Instapaper, but Pocket is even better: it allows me to tag as I add, and has better integration into things like Hootsuite.

However, sometimes I find myself somewhere with no wifi (a plane, the boonies, our office bathroom, etc.) with a few dozen open tabs and no way of getting them into Pocket.

I found a great article [Ryan Toohill](http://blog.ryantoohil.com/2012/03/using-safaris-reading-list-to-feed-instapaper.php) where he wrote a background task for syncing Reading List to Instapaper. This fork is an attempt to do the same for Pocket.

## Setup
* Clone the repo
* chmod +x readinglist_to_pocket.rb
* Open readinglist_to_pocket.rb and edit the credentials to be your Pocket credentials
* Install the necessary gems. I should include a gemfile or something. I'll do that at some point.
* Open com.ryantoohil.readinglisttopocket.plist and change the paths to match your paths (the path to the ruby script, and the path to your Safari Bookmarks.plist). This should be pretty obvious.
* launchctl load <plist file>. This will load up the plist as a launchagent.

That should pretty much be it. Open up Safari and add something to the Reading List. A few seconds later, you should see a little Growl popup (assuming you have Growl installed) that tells you if it succeeded to add the article.

## Revisions
* July 9, 2013: Ported to use Pocket instead of Instapaper
* May 6, 2012: Removed rails dependency and cleaned up DateTime usage. I think.
* Mar 31, 2012: Initial Commit
