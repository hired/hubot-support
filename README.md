### Chat Support with Hubot

This module relays conversations between the web and wherever your Hubot lives.


#### Quick Start

* `cd [your/hubot/repo]`
* `npm --save install hubot-support`
* Add 'hubot-support' to your `external-scripts.json`
    * This confused me once, so, FYI it's a JSON file with a single array of strings, each of which
    is a module name (i.e. `hubot-support`) NOT a script path (i.e. `hubot-support.coffee`)
* Start Hubot
    `PORT=5000 bin/hubot -n bot`
* Visit `http://localhost:5000` (or whatever PORT you picked)
    * Enter your name
    * Press return
    * Send some messages to yourself
* Respond to your messages in the Hubot shell with `bot support [name-of-client] go read the manual`
* See all connected clients with `bot support`

#### Customize the UI

You'll probably want to style up your frontend (like we did at https://chat-support.hired.com)
so you can set the `HUBOT_SUPPORT_FRONTEND_DIR` environment variable to a directory
relative to Hubot's root where the frontend lives.  Hubot will serve this directory,
statically, at `/`.  (I'll make that route configurable soon).

For an example, take a look at the `fe` directory in this repo.  It's a simple
frontend bundle (meant for assembly with my tool - http://github.com/dashkb/fetool)
that present a client app.  Experiment with how far you can modify it; behind the scenes
Backbone is managing the views so I wouldn't change any element classes or ids that look
semantic.  The Fortitude classes (xs-pt1 and friends) are safe to change
