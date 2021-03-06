package TTF::OS_2;

=head1 NAME

TTF::OS_2 - the OS/2 table in a TTF font

=head1 DESCRIPTION

The OS/2 table has two versions and forms, one an extension of the other. This
module supports both forms and the switching between them.

=head1 INSTANCE VARIABLES

No other variables than those in table and those in the standard:

    Version
    xAvgCharWidth
    usWeightClass
    usWidthClass
    fsType
    ySubscriptXSize
    ySubScriptYSize
    ySubscriptXOffset
    ySubscriptYOffset
    ySuperscriptXSize
    ySuperscriptYSize
    ySuperscriptXOffset
    ySuperscriptYOffset
    yStrikeoutSize
    yStrikeoutPosition
    sFamilyClass
    bFamilyType
    bSerifStyle
    bWeight
    bProportion
    bContrast
    bStrokeVariation
    bArmStyle
    bLetterform
    bMidline
    bXheight
    ulUnicodeRange1
    ulUnicodeRange2
    ulUnicodeRange3
    ulUnicodeRange4
    achVendID
    fsSelection
    usFirstCharIndex
    usLastCharIndex
    sTypoAscender
    sTypoDescender
    sTypoLineGap
    usWinAscent
    usWinDescent
    ulCodePageRange1
    ulCodePageRange2
    xHeight
    CapHeight
    defaultChar
    breakChar
    maxLookups

Notice that versions 0, 1 & 2 of the table are supported. Notice also that the
Panose variable has been broken down into its elements.

=head1 METHODS

=cut

use strict;
use vars qw(@ISA @fields @lens);
use TTF::Table;
@ISA = qw(TTF::Table);

use TTF::Utils;

sub init
{
    my ($k, $v, $c, $n, $i);

    $n = 0;
    @lens = (76, 84, 94);
    while (<TTF::OS_2::DATA>)
    {
        if (m/^\s*$/)
        {
            $n++;
            next;
        }
        ($k, $v, $c) = TTF_Init_Fields($_, $c);
        next unless $k ne "";
        for ($i = $n; $i < 3; $i++)
        { $fields[$i]{$k} = $v; }
    }
}


=head2 $t->read

Reads in the various values from disk (see details of OS/2 table)

=cut

sub read
{
    my ($self) = @_;
    my ($dat, $ver);

    $self->SUPER::read or return $self;

    init unless defined $fields[2]{'xAvgCharWidth'};
    read($self->{' INFILE'}, $dat, 2);
    $ver = unpack("n", $dat);
    $self->{'Version'} = $ver;
    if ($ver < 3)
    {
        read($self->{' INFILE'}, $dat, $lens[$ver]);
        TTF_Read_Fields($self, $dat, $fields[$ver]);
    }
    $self;
}


=head2 $t->out($fh)

Writes the table to a file either from memory or by copying.

=cut

sub out
{
    my ($self, $fh) = @_;
    my ($ver);

    return $self->SUPER::out($fh) unless $self->{' read'};

    $ver = $self->{'Version'};
    print $fh pack("n", $ver);
    print $fh TTF_Out_Fields($self, $fields[$ver], $lens[$ver]);
    $self;
}


=head2 $t->update

Updates the C<firstChar> and C<lastChar> values based on the MS table in the
cmap.

=cut

sub update
{
    my ($self) = @_;
    my ($map, $temp);

    return undef unless $self->{' PARENT'}{'cmap'}{' isDirty'};
    $self->{' PARENT'}{'cmap'}->update;
    $map = $self->{' PARENT'}{'cmap'}->find_ms || return undef;

    $self->{'usFirstCharIndex'} = $map->{'val'}[0]->{'START'};
    $temp = $map->{'val'}[$#{$map->{'val'}} - 1];
    $self->{'usLastCharIndex'} = $temp->{'START'} + $temp->{'LEN'} - 1;
    $self;
}

1;

=head1 BUGS

None known

=head1 AUTHOR

Martin Hosken L<Martin_Hosken@sil.org>. See L<TTF::Font> for copyright and
licensing.

=cut


__DATA__
xAvgCharWidth, s
usWeightClass, S
usWidthClass, S
fsType, s
ySubscriptXSize, s
ySubScriptYSize, s
ySubscriptXOffset, s
ySubscriptYOffset, s
ySuperscriptXSize, s
ySuperscriptYSize, s
ySuperscriptXOffset, s
ySuperscriptYOffset, s
yStrikeoutSize, s
yStrikeoutPosition, s
sFamilyClass, s
bFamilyType, C
bSerifStyle, C
bWeight, C
bProportion, C
bContrast, C
bStrokeVariation, C
bArmStyle, C
bLetterform, C
bMidline, C
bXheight, C
ulUnicodeRange1, L
ulUnicodeRange2, L
ulUnicodeRange3, L
ulUnicodeRange4, L
achVendID, L
fsSelection, S
usFirstCharIndex, S
usLastCharIndex, S
sTypoAscender, S
sTypoDescender, S
sTypoLineGap, S
usWinAscent, S
usWinDescent, S

ulCodePageRange1, L
ulCodePageRange2, L

xHeight, s
CapHeight, s
defaultChar, S
breakChar, S
maxLookups, s

