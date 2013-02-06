package Lingua::RO::Numbers;

use strict;
use warnings;
use encoding qw(UTF-8);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(number_to_ro);

our $doua      = 'două';
our $minus     = 'minus';
our $dec_point = 'virgulă';

=encoding utf8

=head1 NAME

Lingua::RO::Numbers - Converts numeric values into their Romanian string equivalents

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

our %table = (
              0  => 'zero',
              1  => 'unu',
              2  => 'doi',
              3  => 'trei',
              4  => 'patru',
              5  => 'cinci',
              6  => 'șase',
              7  => 'șapte',
              8  => 'opt',
              9  => 'nouă',
              10 => 'zece',
              11 => 'unsprezece',
              12 => 'doisprezece',
              13 => 'treisprezece',
              14 => 'paisprezece',
              15 => 'cincisprezece',
              16 => 'șaisprezece',
              17 => 'șaptesprezece',
              18 => 'optsprezece',
              19 => 'nouăsprezece',
             );

# See: http://ro.wikipedia.org/wiki/Sistem_zecimal#Denumiri_ale_numerelor

our @bignums = (
                [10**2, {sg => 'sută', pl => "sute", fem => 1}],
                [10**3, {sg => 'mie',   pl => 'mii',  fem => 1}],
                [10**6,  {sg => 'milion',      pl => 'milioane'}],
                [10**9,  {sg => 'miliard',     pl => 'miliarde'}],
                [10**12, {sg => 'bilion',      pl => 'bilioane'}],
                [10**15, {sg => 'biliard',     pl => 'biliarde'}],
                [10**18, {sg => 'trilion',     pl => 'trilioane'}],
                [10**21, {sg => 'triliard',    pl => 'triliarde'}],
                [10**24, {sg => 'cvadrilion',  pl => 'cvadrilioane'}],
                [10**27, {sg => 'cvadriliard', pl => 'cvadriliarde'}],
               );

=head1 SYNOPSIS

 use Lingua::RO::Numbers qw(number_to_ro);
 print scalar number_to_ro(315);
 # prints 'trei sute cincisprezece'

 print scalar number_to_ro(325.12)
 # prints 'trei sute douăzeci și cinci virgulă doisprezece'

=head1 DESCRIPTION

Lingua::RO::Numbers converts arbitrary numbers into human-oriented
Romanian text. The interface is sligtly different from that defined
for Lingua::EN::Numbers, for one it can be used in a procedural way,
just like Lingua::IT::Numbers, importing the B<number_to_ro> function.

=head2 EXPORT

Nothing is exported by default. The following function is exported.

=over

=item B<number_to_ro($number)>

Converts a number to its Romanian string representation.

  $string = number_to_ro($number);  # returns a string
  @array = number_to_ro($number);   # returns a list

=back

=cut

sub number_to_ro {
    my ($number) = @_;

    my @words;
    if ($number < 0) {    # example: -43
        push @words, $minus;
        push @words, number_to_ro(abs($number));
    }
    elsif ($number < 1 && $number != 0) {    # example: 0.123
        push @words, $table{0};
        push @words, $dec_point;
        my $l = length($number) - 2;

        until ($number == int($number)) {
            $number *= 10;
            $l--;
            $number = sprintf("%.${l}f", $number);    # because of imprecise multiplication
            push @words, $table{0} if $number < 1;
        }
        push @words, number_to_ro(int $number);
    }
    elsif ($number > 1 and $number != int($number)) {    # example: 12.43
        my $l = length($number) - length(int $number) - 1;
        if ($l < 1) {
            push @words, number_to_ro(sprintf("%.0f", $number));
        }
        else {
            my $diff = sprintf("%.${l}f", $number - int($number));
            push @words, number_to_ro(int($number));
            push @words, number_to_ro($diff);
        }
    }
    elsif (exists $table{$number}) {                     # example: 8
        push @words, $table{$number};
    }
    elsif ($number >= $bignums[0][0]) {                  # i.e.: >= 100
        foreach my $i (0 .. $#bignums - 1) {
            my $j = $#bignums - $i;

            if ($number >= $bignums[$j - 1][0] && $number < $bignums[$j][0]) {
                my $cat = int $number / $bignums[$j - 1][0];
                $number -= $bignums[$j - 1][0] * int($number / $bignums[$j - 1][0]);

                my @of = $cat < 2 ? 0 : do {
                    my @w = exists $table{$cat} ? $table{$cat} : (number_to_ro($cat), 'de');
                    if (@w > 2) {
                        $w[-2] = $doua if $w[-2] eq $table{2};
                    }
                    @w;
                };

                if ($cat >= 100 && $cat < 1_000) {
                    my $rest = $cat - 100 * int($cat / 100);
                    if (@of and $rest != 0 and exists $table{$rest}) {
                        splice @of, -1;    # remove 'de'
                    }
                }

                push @words,
                    $cat == 1 ? ($bignums[$j - 1][1]{fem} ? 'o' : 'un', $bignums[$j - 1][1]{sg})
                  : $cat == 2 ? ($doua, $bignums[$j - 1][1]{pl})
                  :             (@of,   $bignums[$j - 1][1]{pl});

                push @words, number_to_ro($number) if $number > 0;
                last;
            }
        }
    }
    elsif ($number > 19 && $number < 100) {    # example: 42
        my $cat = int $number / 10;
        push @words, ($cat == 2 ? $doua : $cat == 6 ? 'șai' : $table{$cat}) . 'zeci',
          ($number % 10 != 0 ? ('și', $table{$number % 10}) : ());
    }

    for my $i (2 .. $#words) {
        if ($words[$i] eq $dec_point and $words[$i - 1] eq $table{0} and $words[$i - 2] ne $minus) {
            splice(@words, $i - 1, 1);
            last;
        }
    }

    return wantarray ? @words : @words ? join(' ', @words) : ();
}

=head1 AUTHOR

Suteu "Trizen" Daniel, C<< <trizenx at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lingua-ro-numbers at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lingua-RO-Numbers>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Lingua::RO::Numbers


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-RO-Numbers>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Lingua-RO-Numbers>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Lingua-RO-Numbers>

=item * Search CPAN

L<http://search.cpan.org/dist/Lingua-RO-Numbers/>

=back


=head1 ACKNOWLEDGEMENTS

    http://ro.wikipedia.org/wiki/Sistem_zecimal#Denumiri_ale_numerelor


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Suteu "Trizen" Daniel.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of Lingua::RO::Numbers

__END__
