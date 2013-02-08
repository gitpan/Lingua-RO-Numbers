use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Lingua::RO::Numbers',
    license             => 'Artistic_2_0',
    dist_author         => q{Șuteu "Trizen" Daniel <trizenx@gmail.com>},
    dist_version_from   => 'lib/Lingua/RO/Numbers.pm',

    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup     => [ 'Lingua-RO-Numbers-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();