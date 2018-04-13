#!perl
use 5.008001;
use strict;
use warnings;

use Test::More;

use File::Slurper qw(read_text);
use File::Temp qw(tempfile);
use Log::Log4cplus;

my @log_levels = (qw(emergency panic fatal critical error warning notice basic info debug trace));

sub capture(&)
{
    my $code = shift;
    my ($oriout, $orierr);
    my ($outfh, $outnm, $errfh, $errnm);
    my ($stdout, $stderr, $exit);

    open($oriout, ">&STDOUT") or die "STDOUT: $!";
    ($outfh, $outnm) = tempfile(
        "XXXXXX",
        SUFFIX => ".out",
        UNLINK => 0
    );
    close(STDOUT);
    open(STDOUT, ">", $outnm) or die "STDOUT: $!";

    open($orierr, ">&STDERR") or die "STDERR: $!";
    ($errfh, $errnm) = tempfile(
        "XXXXXX",
        SUFFIX => ".err",
        UNLINK => 0
    );
    close(STDERR);
    open(STDERR, ">&", $errfh) or die "STDERR: $!";

    select STDOUT;
    $| = 1;
    select STDERR;
    $| = 1;

    $exit = $code->();

    close(STDERR);
    open(STDERR, ">&", $orierr);
    close($errfh);
    close($orierr);
    $stderr = read_text($errnm);
    unlink($errnm);

    close(STDOUT);
    open(STDOUT, ">&", $oriout);
    close($outfh);
    close($oriout);
    $stdout = read_text($outnm);
    unlink($outnm);

    return ($stdout, $stderr, $exit);
}

my $logger = Log::Log4cplus->new(config_basic => 1);
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
