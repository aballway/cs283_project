# cs283_project
It's Storyteim

This is my final project for CS283 - Computer Networks at Vanderbilt University.  Try not to use this code to cheat on any assignments (though I doubt any assignment will be similar to this).

The website (when live) can be found at www.storyteim.com

It is build using the Haskell framework Yesod, PostgreSQL, JavaScript, CSS, and deployed using the Haskell tool Keter on an Amazon EC2 instance.

It has two pages, the write page and the read page.  The write page accepts a title (1 <= characters <= 80) and a story (characters > 140)

It can handle huge text input (e.g. the full text of the King James Bible, Les Misérables, etc.), and is protected against basic SQL injection attacks.

The site is designed to be the antithesis of twitter.  While twitter is about sharing brief thoughts with friends, storyteim is about anonymously sharing deeply personal stories with a group of people looking to do the same.  It is a reaction against the pressures one feels when trying to express oneself honestly without harming one's career.

A special thanks to Josh Palmer (https://github.com/palmerjh), Riley Stewart (https://github.com/ristew), and Benjamin Williams(https://github.com/benjamin-j-williams) for the work we did at VandyHacks on the first version of Storytiem, which led me to want to build it for this class.  This code can be found at https://github.com/haxromana/storytiem
