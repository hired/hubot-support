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

#### Environment Variables

* `HUBOT_SUPPORT_FRONTEND_DIR` - location of support frontend
* `HUBOT_SUPPORT_EMAIL` - your support team's email, in case you are not home

#### Customize the UI

You'll probably want to style up your frontend (like we did at https://chat-support.hired.com)
so you can set the `HUBOT_SUPPORT_FRONTEND_DIR` environment variable to a directory
relative to Hubot's root where the frontend lives.  Hubot will serve this directory,
statically, at `/`.  (I'll make that route configurable soon).

For an example, take a look at the `fe` directory in this repo.  It's a simple
frontend bundle (meant for assembly with my tool - http://github.com/dashkb/fec)
that present a client app.  Experiment with how far you can modify it; behind the scenes
Backbone is managing the views so I wouldn't change any element classes or ids that look
semantic.  The Fortitude classes (xs-pt1 and friends) are safe to change

#### Hacking

Prereq: you should be familiar with hacking on Node.js projects, and some
Hubot scripting experience might help.

* Install my `fec` globally with `npm -g i fec`
* Use `npm link` in this project ([docs](https://www.npmjs.org/doc/cli/npm-link.html))
* `npm link hubot-support` to itself; necessary only if you use the default UI
* Clone a fresh hubot for testing from github.com/github/hubot
* `npm link hubot-support` in the Hubot clone

Ok now this next part kinda sucks and I'm going to automate it at some point.  Background:
there are two things this project builds: the *client* and the *frontend*.  The
frontend depends on the client.

The *frontend* is built by running `fec [--compress]`.  Without rebuilding
the frontend, only backend changes (i.e. to `index.coffee` or files in the `server`
dir) will affect your Hubot.  (You'll still have to restart Hubot for backend
changes to take effect.)

The *client* is built by running `bin/export-[debug-]client` in this project.  You
MUST rebuild the frontend after exporting the client; else you'll be frustrated
when your changes don't show up.  (See `fe/fe.coffee` for why; it's also the
reason we `npm link` the project to itself.)

