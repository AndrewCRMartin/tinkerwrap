#!/usr/bin/perl
use strict;
use Cwd qw(abs_path);

# Add the path of the executable to the library path
use FindBin;
use lib $FindBin::Bin;
# Or if we have a bin directory and a lib directory
#use FindBin;
#use lib abs_path("$FindBin::Bin/../lib");
my $tinkerRoot = abs_path($FindBin::Bin);


my $pdbfile=shift(@ARGV);

my $params="amber99";
my $bindir="$tinkerRoot/bin";
my $paramdir="$tinkerRoot/DATA/tinkerParams";
my $paramfile="$paramdir/$params";
my $pdbhstrip="$bindir/pdbhstrip";
my $pdbrenum="$bindir/pdbrenum";
my $tinkerpatch="$bindir/tinkerpatch";

my $basefile = $pdbfile;
$basefile =~ s/\.pdb$//;
$basefile =~ s/\.ent$//;
`rm -f $basefile.xyz* $basefile.pdb_* $basefile.seq* foo.*`;
my $seqfile="$basefile.seq";
my $xyzfile="$basefile.xyz";
my $xyz2file="${xyzfile}_2";
my $resultfile="${basefile}_result.pdb";

my $pdbxyz="$bindir/pdbxyz";
my $minimize="$bindir/minimize";
my $xyzpdb="$bindir/xyzpdb";

# Convert to xyz
### We need to check for alternate occupancies first ###
`$pdbrenum $pdbfile tmp_$$.pdb`;
$pdbfile = "tmp_$$.pdb";
system("$pdbxyz $pdbfile ALL ALL $paramfile");

# Cartesian minimization
system("$minimize $xyzfile $paramfile 2");

# Convert results to pdb
`cp $xyz2file foo.xyz`;
`cp $seqfile  foo.seq`;
`$xyzpdb foo.xyz $paramfile`;
`$tinkerpatch $pdbfile foo.pdb | $pdbhstrip > $resultfile`;
`rm -f foo.xyz foo.seq foo.pdb`;

# Remove intermediate files
`rm $xyzfile $xyz2file $seqfile`;


