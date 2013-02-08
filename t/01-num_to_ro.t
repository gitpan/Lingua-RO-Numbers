#!perl -T
use 5.006;
use strict;
use encoding qw(UTF-8);
use warnings FATAL => 'all';
use Test::More;

plan tests => 22;

BEGIN {
    use_ok('Lingua::RO::Numbers') || print "Bail out!\n";

    is(scalar Lingua::RO::Numbers::number_to_ro(3),               'trei');
    is(scalar Lingua::RO::Numbers::number_to_ro(0.001),           'zero virgulă zero zero unu');
    is(scalar Lingua::RO::Numbers::number_to_ro(0.139),           'zero virgulă o sută treizeci și nouă');
    is(scalar Lingua::RO::Numbers::number_to_ro(3.14),            'trei virgulă paisprezece');
    is(scalar Lingua::RO::Numbers::number_to_ro(12.26),           'doisprezece virgulă douăzeci și șase');
    is(scalar Lingua::RO::Numbers::number_to_ro(-9_960),          'minus nouă mii nouă sute șaizeci');
    is(scalar Lingua::RO::Numbers::number_to_ro(1_000),           'o mie');
    is(scalar Lingua::RO::Numbers::number_to_ro(4_200),           'patru mii două sute');
    is(scalar Lingua::RO::Numbers::number_to_ro(10_017),          'zece mii șaptesprezece');
    is(scalar Lingua::RO::Numbers::number_to_ro(62_000),          'șaizeci și două de mii');
    is(scalar Lingua::RO::Numbers::number_to_ro(112_000),         'o sută doisprezece mii');
    is(scalar Lingua::RO::Numbers::number_to_ro(120_000),         'o sută douăzeci de mii');
    is(scalar Lingua::RO::Numbers::number_to_ro(1_012_000),       'un milion doisprezece mii');
    is(scalar Lingua::RO::Numbers::number_to_ro(102_000_000),     'o sută două milioane');
    is(scalar Lingua::RO::Numbers::number_to_ro(1_500_083),       'un milion cinci sute de mii optzeci și trei');
    is(scalar Lingua::RO::Numbers::number_to_ro(1_114_000_000),   'un miliard o sută paisprezece milioane');
    is(scalar Lingua::RO::Numbers::number_to_ro(119_830_000),     'o sută nouăsprezece milioane opt sute treizeci de mii');
    is(scalar Lingua::RO::Numbers::number_to_ro(1_198_300_000),   'un miliard o sută nouăzeci și opt de milioane trei sute de mii');
    is(scalar Lingua::RO::Numbers::number_to_ro(11_983_000_000),  'unsprezece miliarde nouă sute optzeci și trei de milioane');
    is(scalar Lingua::RO::Numbers::number_to_ro(119_830_000_000), 'o sută nouăsprezece miliarde opt sute treizeci de milioane');
    is(scalar Lingua::RO::Numbers::number_to_ro(-0.688121),       'minus zero virgulă șase sute optzeci și opt de mii o sută douăzeci și unu');
}
