#!perl

use strict;
use warnings;

use Test::More;
use Test::PerlTidy;

run_tests(
    perltidyrc => '.perltidyrc',
    exclude    => ['inc/latest', 'inc/inc_*', 'travis-perl-helpers']
);
