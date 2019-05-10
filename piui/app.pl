#!/usr/bin/perlml

use strict;
use warnings;

# use CGI::Carp qw(fatalsToBrowser);

use FindBin '$Script';
use MIME::Base64;
use Mojolicious::Lite;
use Mojolicious::Plugin::Authentication;
use Mojo::Util qw(secure_compare);



hook before_dispatch => sub {
    my $self = shift;
    
    if (-1 != index $self->req->url->base->to_string, $Script) {
        my ($base_path) = $self->req->url->base->to_string =~ /^(.*?)$Script/ if 1;
        $self->req->url->base( Mojo::URL->new( $base_path ) );
    }
    
    # $self->req->url->base( Mojo::URL->new( 'https://domain.com/path/more-path/' ) );
};

plugin Config => { file => 'app.json' };

plugin 'authentication', {
    autoload_user => 1,
    load_user => sub {
        my $self = shift;
        my $uid  = shift;

        return {
            'username' => undef,
            'name'     => 'Username'
            } if $uid eq 'userid';
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

helper get_flag => sub {
    my $self = shift;
    my $flag = Mojo::File->new('flag.dat')->slurp;
    ($flag) = $flag =~ /.*(\d)/;
    return $flag;
};

# ------------------------------------

get '/' => sub {
    my $self = shift;
    $self->stash( flag => 0 );

    my %user;
    $user{is_authenticated} = $self->is_user_authenticated;

    if ($self->is_user_authenticated) {
        $user{name} = $self->current_user->{name};
        $self->stash( flag => $self->get_flag );
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

post '/toggleflag' => sub {
    my $self = shift;
    
    if ($self->is_user_authenticated) {
        Mojo::File->new('flag.dat')->spurt( $self->get_flag ? 0 : 1 );
    }
    
    $self->redirect_to('index');
};

get '/logout' => sub {
    my $self = shift;
    $self->logout;
    $self->redirect_to('index');
};

post '/processflag' => sub {
    my $self = shift;
    if (defined($self->req->headers->authorization)
        && secure_compare(
            $self->req->headers->authorization, 
            'Basic '.encode_base64(app->config->{auth_key},'')
        )) {
        my $flag = $self->get_flag;
        Mojo::File->new('flag.dat')->spurt('0');
        return $self->render(
            status => 200,
            json => { flag => $flag // '0' },
        );
    }
    else {
        return $self->render(
            status => 401,
            json => { error => 'Authorization required.' },
        );
    }
    
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
