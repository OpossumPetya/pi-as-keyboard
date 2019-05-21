#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use Proc::Daemon;

my $daemon = Proc::Daemon->new(
	work_dir     => "$FindBin::Bin",
	child_STDOUT => "$FindBin::Bin/client.log",
	child_STDERR => '+>>client.err',
	pid_file     => 'client.pid', # kill -9 PID-NUM (number from .pid file)
	exec_command => "perl $FindBin::Bin/client.pl",
);

my $pid = $daemon->Init();
