
use strict;
use warnings;

# use CGI::Carp qw(fatalsToBrowser);

use Mojolicious::Lite;
use Mojolicious::Plugin::Authentication;

use lib 'lib';
use HidReport;

plugin Config => { file => 'app.json' };

plugin 'authentication', {
    autoload_user => 1,
    load_user => sub {
        my $self = shift;
        my $uid  = shift;

        return {
            'username' => undef,
            'name'     => 'Username'
            } if ( $uid eq 'userid' );
        return undef;
    },
    validate_user => sub {
        my $self = shift;
        my $username = shift;
        my $password = shift || '';

        return 'userid' if $password eq app->config->{admin_pass};
        return undef;
    },
};

# ------------------------------------

get '/' => sub {
    my $self = shift;

    my %user;
    $user{is_authenticated} = $self->is_user_authenticated;

    if ($self->is_user_authenticated) {
        $user{name} = $self->current_user->{name};
    }

    $self->stash( user => \%user );
} => 'index';


post '/login' => sub {
    my $self = shift;

    $self->authenticate(
        undef, # username is not used in this app, but this param is required by the Auth plugin
        $self->req->param('secret')
    );

    $self->redirect_to('index');
};

post '/sendpass' => sub {
    my $self = shift;
    # say HidReport::hex_print_str('abc');
    HidReport::send_ascii_str_as_hid_report( app->config->{pc_pass} );
    $self->redirect_to('index');
};

get '/logout' => sub {
    my $self = shift;
    $self->logout;
    $self->redirect_to('index');
};

any '*' => sub {
    my $self = shift;
    $self->redirect_to('index');
};

app->secrets( app->config->{app_secrets} );
app->config( hypnotoad => {listen => ['http://*:80']} );
app->mode('production');
app->start;
