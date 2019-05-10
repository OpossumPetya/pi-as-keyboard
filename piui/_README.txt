
This app is intended to run on shared hosting. But it should also run fine from under `morbo`, for development.

When running under Morbo
------------------------
Only tested on Windows -- not sure if the shebang from shared hosting would interfere on *nix systems (it's ignored on Win).


When running on shared hosting
------------------------------
Only tested with Cpanel-based hosting.

Ensure:
- Perl 5.10.1 or newer is installed
- Install all needed modules via CPanel
- don't forget 755 on the app.pl
- .htaccess is important: makes perl scripts runnable in that folder + makes "pretty urls" work
- double check the shebang vs your hoster's instructions (see CPanel's "Perl Modules" section)
- in templates use the <%= url_for("/path")->to_abs %> for links, so they work on both hosting and morbo
