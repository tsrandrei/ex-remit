<img src="assets/static/images/favicon.png" alt="" width="200" />

# Remit

A self-hosted web app for [commit-by-commit code review](https://thepugautomatic.com/2014/02/code-review/), written using [Phoenix](https://www.phoenixframework.org/) [LiveView](https://github.com/phoenixframework/phoenix_live_view).

A lab project by [Henrik](https://henrik.nyh.se) started ca 2020-05-15. [See status.](https://github.com/barsoom/ex-remit/issues/1)

## What's the big idea?

You'll add a GitHub webhook to each repo you want to review (see instructions below). This means GitHub sends all new commits and comments to Remit.

Remit shows commits and lets you mark them as reviewed. Clicking a commit opens the commit page on GitHub, where you can write comments either line-by-line or on the commit as a whole.

Remit also shows you comments and lets you mark these as resolved, so you don't miss the feedback you got.

When new commits and comments arrive, or when a co-worker starts a review, you see it all in real time thanks to the magic of WebSockets.

### Setting it up

See instructions below.

Once it's set up, visit e.g. <https://your-remit.herokuapp.com?auth_key=YOUR_KEY>.

### Setting up Fluid.app

We recommend putting Remit inside [Fluid.app](https://fluidapp.com/) or equivalent so you can see Remit and the GitHub commit pages side-by-side. (We can't put GitHub inside an iframe, because they disallow it.)

TODO: Instructions

### Without Fluid.app

Links to commits will open in the same browser window/tab every time. So after clicking a link the first time, you can put this tab/window side-by-side with the Remit window (typically by dragging the tab out of the tab bar into its own window).

It won't be as convenient as with Fluid.app, but good in a pinch!

### Stats API

Visit `/api/stats?auth_key=YOUR_KEY` for some statistics.

You can use it on a dashboard or in a chat integration.

## Dev

Assumed to be run *outside* of devbox, at the time of writing.

First time:

    # Ensure that `config/test.exs` and `config/dev.exs` have the right DB config for you.

    # Create DB and migrate:
    mix ecto.setup

    # Verify that tests run:
    mix test

    # Start the server:
    mix phx.server

    # In a a separate shell, get some fake data via the webhook:
    mix wh.commits
    mix wh.comments

Every time:

    mix phx.server

Then visit <http://localhost:4000?auth_key=dev>

### Fake new commits/comments coming in via webhook

Just run either or both of these commands:

    mix wh.commits
    mix wh.comments

They default to adding just a few, but you can pass a count:

    # Add 100 commits via one webhook call.
    mix wh.commits 100

    # Add 100 comments via 100 webhook calls (GitHub sends one per call).
    # May not be listed exactly 100 times in the UI, because we list based on CommentNotifications.
    mix wh.comments 100

### Maintenance

    mix deps.update --all    # Update Hex deps.
    cd assets && npm update  # Update JS deps.
    mix test                 # Verify things didn't break.

### Working on the connection detection

You probably want to temporarily set `code_reloading: false` in dev.exs to make sure Phoenix code reloading doesn't come into it.

To trigger a disconnection detection in dev, you can load Remit, turn off the Phoenix server for several seconds, then turn it back on. This should be detected as a disconnection and the page should be automatically reloaded. See `app.js`.

## Production

Deploy:

    script/deploy

Console:

    script/prodc

Need to reset the DB on Heroku because you've rethought everything about the DB? Carefully:

    heroku pg:info  # Get DB name, e.g. dancing-nimbly-12345
    heroku pg:reset dancing-nimbly-12345
    heroku run "POOL_SIZE=2 mix ecto.migrate"

### Setup

Configure ENV variables for `AUTH_KEY` and `WEBHOOK_KEY`.

Set e.g.

    # 10 is suitable on a free plan. The max is 20, we'll use 2 for one-off dynos, and the rest as a buffer.
    heroku config:set POOL_SIZE=10

Add a webhook on each reviewed repo in GitHub (at Auctionet, we've got scripts to do this in batch).

The hook should be something like:

    Payload URL: https://my-remit.herokuapp.com/webhooks/github?auth_key=your_WEBHOOK_KEY_value
    Content type: application/json
    Secret: (left empty – it's part of the URL instead)
    Select events:
    - Commit comments
    - Pushes

You should see a happy green checkmark on GitHub, and if you click the hook, "Recent Deliveries" should show a successful ping-pong interaction.

### Automatically remove old data

To avoid growing out of your DB plan, set e.g.

    heroku config:set REMOVE_DATA_OLDER_THAN_DAYS=100

The app will schedule a recurring process (`Remit.Periodically`) to remove older data.

### Migrating from the "Review" app

Did you use our old [Review app](https://github.com/barsoom/review)? See `priv/repo/migrate_from_review.exs`.


## What came before

We've reimplemented this app a few times to try out new tech:

* 2020: Remit II in Phoenix LiveView (and also to try out [Tailwind](https://tailwindcss.com/))
* 2016: [Review](https://github.com/barsoom/review) in Phoenix/Elm
* 2014: [Remit I](https://github.com/henrik/remit) in Ruby on Rails with AngularJS and MessageBus
* 2014: [Hubreview](https://github.com/barsoom/hubreview) in Ruby on Rails with WebSockets

## Original instructions

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
