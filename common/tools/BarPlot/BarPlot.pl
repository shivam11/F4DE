#!/usr/bin/env perl

# BarPlot.pl
# Authors: Jonathan Fiscus
#          Martial Michel
# 
# This software was developed at the National Institute of Standards and
# Technology by employees of the Federal Government in the course of
# their official duties.  Pursuant to Title 17 Section 105 of the United
# States Code this software is not subject to copyright protection within
# the United States and is in the public domain. It is an experimental
# system.  NIST assumes no responsibility whatsoever for its use by any
# party.
# 
# THIS SOFTWARE IS PROVIDED "AS IS."  With regard to this software, NIST
# MAKES NO EXPRESS OR IMPLIED WARRANTY AS TO ANY MATTER WHATSOEVER,
# INCLUDING MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.

use strict;
use Data::Dumper;

##########
# Check we have every module (perl wise)

## First insure that we add the proper values to @INC
my ($f4b, @f4bv);
BEGIN {
  $f4b = "F4DE_BASE";
  push @f4bv, (exists $ENV{$f4b}) 
    ? ($ENV{$f4b} . "/lib") 
      : ("../../lib", "../../../common/lib");
}
use lib (@f4bv);

sub eo2pe {
  my @a = @_;
  my $oe = join(" ", @a);
  my $pe = ($oe !~ m%^Can\'t\s+locate%) ? "\n----- Original Error:\n $oe\n-----" : "";
  return($pe);
}

## Then try to load everything
my $have_everything = 1;
my $partofthistool = "It should have been part of this tools' files. Please check your $f4b environment variable.";
my $warn_msg = "";

# Part of this tool
foreach my $pn ("MMisc", "BarPlot") {
  unless (eval "use $pn; 1") {
    my $pe = &eo2pe($@);
    &_warn_add("\"$pn\" is not available in your Perl installation. ", $partofthistool, $pe);
    $have_everything = 0;
  }
}

# usualy part of the Perl Core
foreach my $pn ("Getopt::Long", "Pod::Usage", "File::Temp") {
  unless (eval "use $pn; 1") {
    &_warn_add("\"$pn\" is not available on your Perl installation. ", "Please look it up on CPAN [http://search.cpan.org/]\n");
    $have_everything = 0;
  }
}

# Something missing ? Abort
if (! $have_everything) {
  print "\n$warn_msg\nERROR: Some Perl Modules are missing, aborting\n";
  exit(1);
}

my $VERSION = 0.1;
my $inputCSV = undef;
my $title = undef;
my $man = undef;
my $v = undef;
my $help = undef;
my $root = undef;

Getopt::Long::Configure(qw( no_ignore_case ));

GetOptions
  (
   'c|csv=s'         => \$inputCSV,
   't|title=s'       => \$title,
   'version'         => sub { my $name = $0; $name =~ s/.*\/(.+)/$1/; print "$name version $VERSION\n"; exit(0); },
   'h|help'          => \$help,
   'v|verbose'       => \$v,
   'r|root=s'        => \$root,
   'm|man'           => \$man,
  );

## Docs
pod2usage(1) if $help;
pod2usage(-exitvalue => 0, -verbose => 2) if $man;
##

die if ! defined($inputCSV);
die if ! defined($root);

my $at = new AutoTable;
$at->loadCSV($inputCSV);
print $at->renderTxtTable(2);
my $bp = new BarPlot();

my @rowIDs = $at->getRowIDs("AsAdded");
my @colIDs = $at->getColIDs("AsAdded");
foreach my $row(@rowIDs){
    foreach my $col(@colIDs){
	$bp->addData($row, $col, $at->getData($row,$col));
    }
}

$bp->horizontal("TRUE");
$bp->makePlot($root);

exit 0;

#############################################  End of the program #########################################

sub _warn_add
{
	$warn_msg .= "[Warning] " . join(" ", @_) . "\n";
}

__END__

=head1 NAME

DETMerge.pl -- Merge multiple serialized DET Curve.

=head1 SYNOPSIS

B<DETMerge.pl> [--help | --man | --version] [--verbose] --output-srl file [--title "title"] [--ZipPROG prog] [--MergeType type] input_srl [input_srl [...]]

=head1 DESCRIPTION

The script merge multiple serialized DET Curve generated by the F4DE package.

=head1 OPTIONS

=over

=item B<--output-srl> 

Specifiy the output file.

=item B<--title> S<"title">

Specify a new title.

=item B<--ZipPROG> F<GZIP_PATH>

Specify the full path name to gzip (default: 'gzip').

=item B<--MergeType> I<type>

Specify the type of merge to perform

=item B<--help>

Print the help.

=item B<--man>

Print the manual.

=item B<--version>

Print the version number.

=back

=head1 BUGS

No known bugs.

=head1 NOTES

The default iso-cost ratio coefficients (-R option) and iso-metric coefficients (-Q option) are defined into the metric.

=head1 AUTHOR

 Jonathan Fiscus <jonathan.fiscus@nist.gov>
 Jerome Ajot <jerome.ajot@nist.gov>
 Martial Michel <martial.michel@nist.gov>

=head1 VERSION

DETUtil.pl version 0.4

=head1 COPYRIGHT 

This software was developed at the National Institute of Standards and Technology by employees of the Federal Government in the course of their official duties.  Pursuant to Title 17 Section 105 of the United States Code this software is not subject to copyright protection within the United States and is in the public domain. It is an experimental system.  NIST assumes no responsibility whatsoever for its use by any party.

THIS SOFTWARE IS PROVIDED "AS IS."  With regard to this software, NIST MAKES NO EXPRESS OR IMPLIED WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.

=cut
