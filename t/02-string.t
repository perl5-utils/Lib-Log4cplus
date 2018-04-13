#!perl
use 5.008001;
use strict;
use warnings;

use Test::More;

use Capture::Tiny 'capture';
use Log::Log4cplus;

my @log_levels = (qw(emergency panic fatal critical error warning notice basic info debug trace));

my $props = <<EOP;
log4cplus.rootLogger=DEBUG, STDOUT
log4cplus.appender.STDOUT=log4cplus::ConsoleAppender
log4cplus.appender.STDOUT.logToStdErr=0
EOP

my $logger = Log::Log4cplus->new(config_string => $props);
foreach my $log_level (@log_levels)
{
    my $is = "is_$log_level";
    ok($logger->$is(), "Testing for log-level $log_level");
    my ($stdout, $stderr, $exit) = capture { $logger->$log_level("Logging in level $log_level"); };
    ok(0 == $exit, "Logged in log-level $log_level");
    like($stdout, qr/Logging in level $log_level$/, "Got logged text in log-level $log_level");
    is($stderr, "", "No error logging in log-level $log_level");
}

done_testing();
