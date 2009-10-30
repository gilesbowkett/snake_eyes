Snake Eyes
==========

Snake Eyes adds [ninja power](http://drmcninja.com/) to [CI Joe](http://github.com/defunkt/cijoe).

![Ninja Power](http://s3.amazonaws.com/giles/mc_ninja_102609/300px-McNinja.png)

CI Joe
======

Joe is a [Continuous
Integration](http://en.wikipedia.org/wiki/Continuous_integration)
server that'll run your tests on demand and report their pass/fail status.

Because knowing is half the battle.

![The Battle](http://img.skitch.com/20090805-g4a2qhttwij8n2jr9t552efn3k.png)

Quickstart
----------

Rip:

    $ rip install git://github.com/defunkt/cijoe.git
    $ git clone git://github.com/you/yourrepo.git
    $ cijoe yourrepo

Gemcutter:

    $ gem install cijoe
    $ git clone git://github.com/you/yourrepo.git
    $ cijoe yourrepo

Boom. Navigate to http://localhost:4567 to see Joe in action.
Check `cijoe -h` for other options.

Basically you need to run `cijoe` and hand it the path to a git
repo. Make sure this isn't a shared repo: Joe needs to own it.

Joe looks for various git config settings in the repo you hand it. For
instance, you can tell Joe what command to run by setting
`cijoe.runner`:

    $ git config --add cijoe.runner "rake -s test:units"

Joe doesn't care about Ruby, Python, or whatever. As long as the
runner returns a non-zero exit status on fail and a zero on success,
everyone is happy.

Need to do some massaging of your repo before the tests run, like
maybe swapping in a new database.yml? No problem - Joe will try to
run `.git/hooks/after-reset` if it exists before each build phase.
Do it in there. Just make sure it's executable.

Want to notify IRC or email on test pass or failure? Joe will run
`.git/hooks/build-failed` or `.git/hooks/build-worked` if they exist
and are executable on build pass / fail. They're just shell scripts -
put whatever you want in there.

Tip: your repo's `HEAD` will point to the commit used to run the
build. Pull any metadata you want out of that scro.


Other Branches
--------------

Want Joe to run against a branch other than `master`? No problem:

    $ git config --add cijoe.branch deploy


Notifiers
---------

CI Joe includes Campfire notification, because it's what they use at GitHub,
where CI Joe came into being. Want Joe to notify your Campfire? Put this in
your repo's `.git/config`:

    [campfire]
    	user = your@campfire.email
    	pass = passw0rd
    	subdomain = whatever
    	room = Awesomeness
    	ssl = false

Or do it the old-fashioned way:

    $ cd yourrepo
    $ git config --add campfire.user chris@ozmm.org
    $ git config --add campfire.subdomain github
    etc.

Snake Eyes gives you an additional option: Gmail. In `.git/config`:

    [gmail]
    	user = your_ci_joe@email
    	pass = passw0rd
    	recipient = developers@your-company.com

Or:

    $ cd yourrepo
    $ git config --add campfire.user your.ci.server@gmail.com
    $ git config --add campfire.password s3cr3t
    etc

If it's not obvious, you do in fact need to have this gmail account and
the password does in fact need to be valid.

CI Joe gives you Campfire (and only Campfire) by default, but Snake Eyes
makes you specify your notifier in your project's `.git/config`. Sorry for
the extra work.

    [cijoe]
    	notifier = CIJoe::Gmail

Or:

    [cijoe]
    	notifier = CIJoe::Campfire

Extending Snake Eyes to support additional notifiers is very, very easy.
Even though Chris Wanstraäth, CI Joe's author, was very, very explicit
about not supporting any kind of notifier except the Campfire notifier,
his code furnishes an API which is very, very extensible and very, very
friendly to repurposing.

The CI Joe Campfire notifier uses a `valid_config?` method to check that the
notifier will be able to work. If so, it loads the Campfire module right into
CI Joe, so that when CI Joe calls `notify`, it's calling the `notify` on the
Campfire module. If you're creating your own notifier module, all you need
to support is an `activate` method on the module itself and a `notify` instance
method. Copying the `valid_config?` pattern is strongly advised but absolutely
not required.

Warning: Snake Eyes enables arbitrary notifiers using a language feature
called `eval`. Many people believe `eval` is evil. All who know it fear
its power. Snake Eyes is comfortable with `eval` because Snake Eyes is a
fucking ninja. If you cut yourself on a sharp piece of `eval`, don't come crying
to Snake Eyes. You'll never find him. Because he's a ninja.

Multiple Projects
-----------------

Want CI for multiple projects? Just start multiple instances of Joe!
He can run on any port - try `cijoe -h` for more options.


HTTP Auth
---------

Worried about people triggering your builds? Setup HTTP auth:

    $ git config --add cijoe.user chris
    $ git config --add cijoe.pass secret


GitHub Integration
------------------

Any POST to Joe will trigger a build. If you are hiding Joe behind
HTTP auth, that's okay - GitHub knows how to authenticate properly.

![Post-Receive URL](http://img.skitch.com/20090806-d2bxrk733gqu8m11tf4kyir5d8.png)

You can find the Post-Receive option under the 'Service Hooks' subtab
of your project's "Admin" tab.


Daemonize
---------

Want to run Joe as a daemon? Use `nohup`:

    $ nohup cijoe -p 4444 repo &


Other CI Servers
----------------

Need more features? Check out one of these bad boys:

* [Cerberus](http://cerberus.rubyforge.org/)
* [Integrity](http://integrityapp.com/)
* [CruiseControl.rb](http://cruisecontrolrb.thoughtworks.com/)
* [BuildBot](http://buildbot.net/trac)

Need less notifiers? Check out the original CI Joe:

* [CI Joe](http://github.com/defunkt/cijoe)


Screenshots
-----------

![Building](http://img.skitch.com/20090806-ryw34ksi5ixnrdwxcptqy28iy7.png)

![Built](http://img.skitch.com/20090806-f7j3r65yecaq13hdcxqwtc5krd.)


Questions? Concerns?
--------------------

For CI Joe:

[Issues](http://github.com/defunkt/cijoe/issues) or [the mailing list](http://groups.google.com/group/cijoe).

( Chris Wanstrath :: chris@ozmm.org )

For Snake Eyes: do not attempt to contact Snake Eyes. Snake Eyes is a ninja.

( Giles Bowkett :: gilesb@gmail.com )
