#!/usr/bin/perl -w

###########################################################
# 
# Convenince script to generate CMake projects for Android 
# for each architecture and build them.
# Copyright (C) PlayControl Software, LLC. 
# Eric Wing <ewing . public @ playcontrol.net>
#
##########################################################


use strict;
use warnings;

# Function to help with command line switches
use Getopt::Long;
# Allows extra "unknown options" to be specified which I will use to pass directly to the cmake executable.
Getopt::Long::Configure("pass_through");

# Function to get the basename of a file
use File::Basename;

# Provides functions to convert relative paths to absolute paths.
use Cwd;


# Global constants
my %kArchToDirectoryNameMap =
(
	arm => "armeabi",
	armv7 => "armeabi-v7a",
	x86 => "x86"
);

my @kSupportedArchitectures =
(
	"arm",
	"armv7",
	"x86"
);


# Function prototypes 

# main routine
sub main();
# call main
main();

sub main()
{
	my ($targetdir, $cmake, $toolchain, $buildtype, $sourcedir, @remaining_options) = extract_parameters();

	# Save in case we need to return to the original current working directory.
#	my $original_current_working_directory = Cwd::cwd();

#	print("targetdir: ", $targetdir, "\n"); 
#	print("cmake: ", $cmake, "\n"); 
#	print("toolchain: ", $toolchain, "\n"); 
#	print("buildtype: ", $buildtype, "\n"); 
#	print("sourcedir: ", $sourcedir, "\n"); 
#	print("remaining_options: ", @remaining_options, "\n"); 

	unless(-e $targetdir or mkdir $targetdir)
	{
		die("Unable to create $targetdir: $!\n");
	}

	foreach my $arch(@kSupportedArchitectures)
	{
		chdir($targetdir) or die("Could not change directory to $targetdir: $!\n");
		my $arch_dir = $kArchToDirectoryNameMap{$arch};
		unless(-e $arch_dir or mkdir $arch_dir)
		{
			die("Unable to create $arch_dir: $!\n");
		}
		chdir($arch_dir) or die("Could not change directory to $arch_dir: $!\n");

		my $arch_flag = "-DANDROID_NDK_ARCH=$arch";
#		print("arch_flag: $arch_flag\n");
		print("Generating $arch\n");
		
#		my $error_status = system($cmake, "$toolchain", "$arch_flag", $buildtype, @remaining_options, $sourcedir);
		my $error_status = system($cmake, $toolchain, $arch_flag, $buildtype, @remaining_options, $sourcedir);
		if($error_status != 0)
		{
			die "Invoking CMake failed: $?\n";
		}

		print("Building $arch\n");
		$error_status = system("make");
		if($error_status != 0)
		{
			die "Invoking make failed: $?\n";
		}
	}

	return;

}


sub helpmenu()
{
	my $basename = basename($0);
	print "Convenience script for generating and building CMake based projects for Android (multiple architectures).\n\n";

	print "Usage: perl $basename [-h | -help] --sourcedir=<path to source> --targetdir=<path to build dir> --toolchain=<CMake toolchain file> [--cmake=<CMake exectuable>] [--buildtype=<None|Debug|Release*|RelWithDebInfo|MinSizeRel>] [<other flags passed to CMake>]\n";

	print "Options:\n";
	print "  -h or -help                              Brings up this help display.\n";
	print "  --sourcedir=<path to source>             Path to the source code directory.\n";
	print "  --targetdir=<path to build directory>    Path to where the CMake projects will be generated. Will be created if doesn't exist.\n";
	print "  --toolchain=<toolchain file>             Path to and file of the CMake toolchain to use.\n";
	print "  --cmake=<CMake executable>               (Optional) Allows you to specify the path and file to the CMake executable.\n";
	print "  --buildtype=<build type>                 (Optional) The CMake Build Type. Default is Release.\n";
	print "\n";
	print "Example Usage:\n";
	print "$basename --sourcedir=../Chipmunk2D/ --targetdir=. --toolchain=../CMake-Toolchain-Collection/toolchain-android-ndk-r9.cmake\n";

	return;
}

# Subroutine to extract and process command line parameters
sub extract_parameters()
{
	my %params = (
		h => \(my $hflag = 0),
		help => \(my $helpflag = 0),
		sourcedir => \(my $sourcedir),
		targetdir => \(my $targetdir),
		toolchain => \(my $toolchain),
		buildtype => \(my $buildtype = "Release"),
		cmake => \(my $cmake)
       );

	# Call Library function which will extract and remove all switches and
	# their corresponding values.
	# These parameters will be removed from @ARGV
	my $errorval = &GetOptions(\%params, "h", "help",
					"sourcedir=s",
					"targetdir=s",
					"toolchain=s",
					"buildtype=s",
					"cmake=s"
	); 
	# the exclaimation point allows for the negation
	# of the switch (i.e. -nobackup/-nobody is a switch)

	# Error value should have returned 1 if nothing went wrong
	# Otherwise, an unlisted parameter was specified.
	if($errorval !=1)
	{
		# Expecting GetOptions to state error.

		print "Exiting Program...\n";
		exit 0;
	}

	if( ($hflag == 1) || ($helpflag == 1) ) 
	{
		helpmenu();
		exit 0;
	}

	if(not defined($sourcedir))
	{
		helpmenu();
		exit 1;
	}

	if(not defined($targetdir))
	{
		helpmenu();
		exit 2;
	}

	if(not defined($toolchain))
	{
		helpmenu();
		exit 3;
	}

	if(not defined($cmake))
	{
		$cmake = "cmake";
	}
	else
	{
		$cmake = Cwd::abs_path($cmake);	
	}
	# Convert to absolute paths because we will be changing directories which will break relative paths.
	$sourcedir = Cwd::abs_path($sourcedir);
	$targetdir = Cwd::abs_path($targetdir);
	# Change the strings to be in the form we need to pass to CMake.
	$toolchain = "-DCMAKE_TOOLCHAIN_FILE=" . Cwd::abs_path($toolchain);
	$buildtype = "-DCMAKE_BUILD_TYPE=$buildtype";

	# This can be optimized out, but is left for clarity. 
	# GetOptions has removed all found options so anything left in @ARGV is "remaining".
	my @remaining_options = @ARGV;

	my @sorted_options = ($targetdir, $cmake, $toolchain, $buildtype, $sourcedir, @remaining_options);
	
	return @sorted_options;
}


