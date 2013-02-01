#!perl -T
use 5.006;
use strict;
use encoding qw(UTF-8);
use warnings FATAL => 'all';
use Test::More;

plan tests => 6;

BEGIN {
    use_ok('Lingua::RO::Numbers') || print "Bail out!\n";

    is(scalar Lingua::RO::Numbers::number_to_ro(3),     'trei');
    is(scalar Lingua::RO::Numbers::number_to_ro(12.26), 'doisprezece virgulă douăzeci și șase');
    is(scalar Lingua::RO::Numbers::number_to_ro(-9960), 'minus nouă mii nouă sute șaizeci');
    is(scalar Lingua::RO::Numbers::number_to_ro(1000),  'o mie');
    is(scalar Lingua::RO::Numbers::number_to_ro(4200),  'patru mii două sute');
}
