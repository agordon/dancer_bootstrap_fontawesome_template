# [WebApp QuickStart Template](http://cowbell.cancan.cshl.edu/)
A template for quick-starting applications using Perl's Dancer, Twitter's Bootstrap, and Font-Awesome.

## Starting a New Application
1. Download the template.
2. Rename `lib/dancer_bootstrap_fontawesome_template.pm` to something relevant for you.
3. Added "bin/app.pl" and change the module name (from step 2).
4. Do your modifications.
5. Profit!

## Updating Twitter Bootstrap
* Quickest way:
```sh
    $ cd /path/to/your/dancer/project
    $ ./bin/update_bootstrap
```

* Manual UNIX Way:
```sh
    $ cd /path/to/your/dancer/project
    $ cd public
    $ mv bootstrap bootstrap.$(date +%F).old
    $ wget http://twitter.github.com/bootstrap/assets/bootstrap.zip
    $ unzip bootstrap.zip
    $ rm bootstrap.zip
```

* Steps are:
    1. Download bootstrap's ZIP file (should be named `bootstrap.zip`) to the `<dancer>/public` directory.
    2. Delete (or rename/move-aside) the current `<dancer>/public/bootstrap` directory .
    3. unzip the bootstrap.zip file in `<dancer>/public`.
    4. The updated `bootstrap` directory will be used automatically.

## Updating Font-Awesome
* Quickest way:
```sh
    $ cd /path/to/your/dancer/project
    $ ./bin/update_fontawesome
```

* Manual UNIX Way:
```sh
    $ cd /path/to/your/dancer/project
    $ cd public
    $ mv FontAwesome FontAwesome.$(date +%F).old
    $ wget -O FontAwesome.zip https://github.com/FortAwesome/Font-Awesome/zipball/master
    $ unzip FontAwesome.zip
    # Here be a catch: the unzip'd directory will be different everytime, depending on the latest GIT version.
    #                  So we rename it using a shell-wildcard, assuming no other directroy is named like this.
    #                  run "ls -l" to see what I mean.
    $ mv FortAwesome-Font-Awesome-* FontAwesome
    $ rm FontAwesome.zip
```
* Steps are:
    1. Download the latest Font-Awesome zipball.
    2. Delete (or rename/move-aside) the current `<dancer>/public/FontAwesome` directory.
    3. unzip the FontAwesome.zip file in `<dancer>/public`.
    4. The updated `FontAwesome` directory will be used automatically.

## Updating jQuery
* Manual UNIX way:
    1. Find out the latest version at [docs.jquery.com/Downloading_jQuery](http://docs.jquery.com/Downloading_jQuery).
    2. Goto `<dancer>/public/javascripts`.
    3. Download the new jQuery file.
    4. Update `<dancer>/views/layout/main.tt` (at the bottom `<script>`) to use the new jQuery.
