package Lingua::RO::Numbers;

use utf8;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(number_to_ro);

=encoding utf8

=head1 NAME

Lingua::RO::Numbers - Converts numeric values into their Romanian string equivalents

=head1 VERSION

Version 0.12

=cut

our $VERSION = '0.12';

our %DIGITS;
@DIGITS{0 .. 19} = qw(
  zero unu doi trei patru cinci șase șapte opt nouă zece
  unsprezece
  doisprezece
  treisprezece
  paisprezece
  cincisprezece
  șaisprezece
  șaptesprezece
  optsprezece
  nouăsprezece
  );

# See: http://ro.wikipedia.org/wiki/Sistem_zecimal#Denumiri_ale_numerelor

our @BIGNUMS = (
                {num => 10**2,  sg => 'sută',        pl => 'sute', fem => 1},
                {num => 10**3,  sg => 'mie',         pl => 'mii',  fem => 1},
                {num => 10**6,  sg => 'milion',      pl => 'milioane'},
                {num => 10**9,  sg => 'miliard',     pl => 'miliarde'},
                {num => 10**12, sg => 'bilion',      pl => 'bilioane'},
                {num => 10**15, sg => 'biliard',     pl => 'biliarde'},
                {num => 10**18, sg => 'trilion',     pl => 'trilioane'},
                {num => 10**21, sg => 'triliard',    pl => 'triliarde'},
                {num => 10**24, sg => 'cvadrilion',  pl => 'cvadrilioane'},
                {num => 10**27, sg => 'cvadriliard', pl => 'cvadriliarde'},
               );

=head1 SYNOPSIS

 use Lingua::RO::Numbers qw(number_to_ro);
 print number_to_ro(315);
 # prints 'trei sute cincisprezece'

 print number_to_ro(325.12)
 # prints 'trei sute douăzeci și cinci virgulă doisprezece'

=head1 DESCRIPTION

Lingua::RO::Numbers converts arbitrary numbers into human-oriented
Romanian text. The interface is sligtly different from that defined
for Lingua::EN::Numbers, for one it can be used in a procedural way,
just like Lingua::IT::Numbers, importing the B<number_to_ro> function.

=head2 EXPORT

Nothing is exported by default. Only the function B<number_to_ro()> is exportable.

=over

=item B<new(;%opt)>

Initialize an object.

    my $obj = Lingua::RO::Numbers->new();

is equivalent with:

    my $obj = Lingua::RO::Numbers->new(
                      diacritics          => 1,
                      invalid_number      => undef,
                      negative_sign       => 'minus',
                      decimal_point       => 'virgulă',
                      thousands_separator => '',
                      infinity            => 'infinit',
                      not_a_number        => 'NaN',
              );

=item B<number_to_ro($number)>

Converts a number to its Romanian string representation.

  # Functional oriented usage
  $string = number_to_ro($number);
  $string = number_to_ro($number, %opts);

  # Object oriented usage
  my $obj = Lingua::RO::Numbers->new(%opts);
  $string = $obj->number_to_ro($number);

  # Example:
  print number_to_ro(98_765, thousands_separator => q{,});
    # says: 'nouăzeci și opt de mii, șapte sute șaizeci și cinci'

=back

=cut

sub new {
    my ($class, %opts) = @_;

    my $self = bless {
                      diacritics          => 1,
                      invalid_number      => undef,
                      negative_sign       => 'minus',
                      decimal_point       => 'virgulă',
                      thousands_separator => '',
                      infinity            => 'infinit',
                      not_a_number        => 'NaN',
                     }, $class;

    foreach my $key (keys %{$self}) {
        if (exists $opts{$key}) {
            $self->{$key} = delete $opts{$key};
        }
    }

    foreach my $invalid_key (keys %opts) {
        warn "Invalid option: <$invalid_key>";
    }

    return $self;
}

sub number_to_ro {
    my ($self, $number, %opts);

    if (ref $_[0] eq __PACKAGE__) {
        ($self, $number) = @_;
    }
    else {
        ($number, %opts) = @_;
        $self = __PACKAGE__->new(%opts);
    }

    my $word_number = $self->_number_to_ro($number);

    if (not $self->{diacritics}) {
        $word_number =~ tr{ăâșțî}{aasti};
    }

    return $word_number;
}

sub _number_to_ro {
    my ($self, $number) = @_;

    my @words;
    if (exists $DIGITS{$number}) {    # example: 8
        push @words, $DIGITS{$number};
    }
    elsif ($number + 0 eq 'nan') {    # not a number (NaN)
        return $self->{not_a_number};
    }
    elsif ($number < 0) {             # example: -43
        push @words, $self->{negative_sign};
        push @words, $self->_number_to_ro(abs($number));
    }
    elsif ($number != int($number)) {    # example: 0.123 or 12.43
        my $l = length($number) - 2;

        if ((length($number) - length(int $number) - 1) < 1) {    # special case
            push @words, $self->_number_to_ro(sprintf('%.0f', $number));
        }
        else {
            push @words, $self->_number_to_ro(int $number);
            push @words, $self->{decimal_point};

            $number -= int $number;

            until ($number == int($number)) {
                $number *= 10;
                $l--;
                $number = sprintf("%.${l}f", $number);            # because of imprecise multiplication
                push @words, $DIGITS{0} if $number < 1;
            }
            push @words, $self->_number_to_ro(int $number);
        }
    }
    elsif ($number >= $BIGNUMS[0]{num}) {                         # i.e.: >= 100
        foreach my $i (0 .. $#BIGNUMS - 1) {
            my $j = $#BIGNUMS - $i;

            if ($number >= $BIGNUMS[$j - 1]{num} && $number < $BIGNUMS[$j]{num}) {
                my $cat = int $number / $BIGNUMS[$j - 1]{num};
                $number -= $BIGNUMS[$j - 1]{num} * int($number / $BIGNUMS[$j - 1]{num});

                my @of = $cat <= 2 ? () : do {
                    my @w = exists $DIGITS{$cat} ? $DIGITS{$cat} : ($self->_number_to_ro($cat), 'de');
                    if (@w > 2) {
                        $w[-2] = 'două' if $w[-2] eq $DIGITS{2};
                    }
                    @w;
                };

                if ($cat >= 100 && $cat < 1_000) {
                    my $rest = $cat - 100 * int($cat / 100);
                    if (@of and $rest != 0 and exists $DIGITS{$rest}) {
                        splice @of, -1;    # remove 'de'
                    }
                }

                push @words,
                    $cat == 1 ? ($BIGNUMS[$j - 1]{fem} ? 'o' : 'un', $BIGNUMS[$j - 1]{sg})
                  : $cat == 2 ? ('două', $BIGNUMS[$j - 1]{pl})
                  :             (@of, $BIGNUMS[$j - 1]{pl});

                $words[-1] .= $self->{thousands_separator} if $BIGNUMS[$j]{num} > 1_000;
                push @words, $self->_number_to_ro($number) if $number > 0;
                last;
            }
        }
    }
    elsif ($number > 19 && $number < 100) {    # example: 42
        my $cat = int $number / 10;
        push @words, ($cat == 2 ? 'două' : $cat == 6 ? 'șai' : $DIGITS{$cat}) . 'zeci',
          ($number % 10 != 0 ? ('și', $DIGITS{$number % 10}) : ());
    }
    elsif ($number == 'inf') {                 # number is infinit
        return $self->{infinity};
    }
    else {                                     # doesn't look like a number
        return $self->{invalid_number};
    }

    return wantarray ? @words : @words ? join(' ', @words) : ();
}

=head1 AUTHOR

Șuteu "Trizen" Daniel, C<< <trizenx at gmail.com> >>

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

Copyright 2013 Șuteu "Trizen" Daniel.

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
