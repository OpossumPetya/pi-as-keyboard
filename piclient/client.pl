#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";    

use Cpanel::JSON::XS;
use Try::Tiny;
use MIME::Base64;
use Mojo::UserAgent;
use HidReport;

$| = 1;

# --------------------------

sub slurp {
    my $file = shift;
    open my $fh, '<', $file or die $!;
      local $/ = undef;
      my $contents = <$fh>;
    close $fh;
    return $contents;
}

my $json_data = slurp("$FindBin::Bin/config.json");
my $config = Cpanel::JSON::XS->new->relaxed(1)->decode($json_data);

# --------------------------

my $ua = Mojo::UserAgent->new;

while(1) {

    my $response = try {
        $ua->post(
            $config->{url} => { 
                Authorization => 'Basic '.encode_base64($config->{auth_key},'')
            }
        );
    };

    if ($response) {
        if ($response->result->is_success) {
            if ($response->result->json->{flag}) {
                HidReport::send_ascii_str_as_hid_report( $config->{pc_pass} );
            }
        }
    }

    sleep 60 * ( defined( $config->{pause} ) && $config->{pause} > 0 ? $config->{pause} : 1 );
}
