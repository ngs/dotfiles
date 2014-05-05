use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => '<MAIN MODULE>',
    AUTHOR              => '<AUTHOR> <<EMAIL>>',
    VERSION_FROM        => '<MAIN PM FILE>',
    ABSTRACT_FROM       => '<MAIN PM FILE>',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => '<DISTRO>-*' },
);
