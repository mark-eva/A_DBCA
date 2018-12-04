#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Copy;


our $SOURCE_TEMPLATE_DIR='/oracle/scripts/A_DBCA/db_templates/';



print "Enter ORACLE_HOME Directory: \n";
our $ORACLE_HOME = <STDIN>;
chomp $ORACLE_HOME;
#================================================================================================================
#Check if the ORACLE_HOME entered by the user is valid								|
#================================================================================================================
our $cmd_valid_home = "ls -altr $ORACLE_HOME| grep -i sqlplus | wc -l";
our $valid = `$cmd_valid_home`;
if ($valid == 1)
{
	print "oracle home is valid you may proceed \n";
}
else
{
	print "The directory you entered is not a valid, try again ORACLE_HOME \n";
	exit ();
}
print "Your chosen Oracle_Home is: $ORACLE_HOME \n";
print "Choose the database Template you want to use \n";
our $cmd_list_files = "ls -altr $SOURCE_TEMPLATE_DIR | grep -i dbc";
our $TARGET_TEMPLATE_DIR="$ORACLE_HOME/assistants/dbca/templates";
system ($cmd_list_files);
our $TEMPLATE_CHOICE=<STDIN>;
print "You have chosen template:$TEMPLATE_CHOICE \n";


#================================================================================================================
#Copy the chosen Template to ORACLE_HOME/dbs                                                                    |
#================================================================================================================

chomp $SOURCE_TEMPLATE_DIR;
chomp $TEMPLATE_CHOICE;
copy("$SOURCE_TEMPLATE_DIR$TEMPLATE_CHOICE","$ORACLE_HOME/assistants/dbca/templates") or die "Copy failed: $!";



#================================================================================================================
#Set Config based on user input                                                                                 |
#================================================================================================================

our $SOURCE_RSP = "/oracle/scripts/A_DBCA/db_templates/general.rsp";
our $TARGET_DEST = "/oracle/scripts/A_DBCA/instance_list/";
chomp $SOURCE_RSP;
chomp $TARGET_DEST;

print "Name of the Database Instance \n";
our $FILE_NAME = <STDIN>;
our $STRING_LENGTH =  length($FILE_NAME);
chomp $FILE_NAME;

if ($STRING_LENGTH <= 8)
{
        copy("$SOURCE_RSP","$TARGET_DEST$FILE_NAME.rsp") or die "Copy failed: $!";
        our $RSP = "$TARGET_DEST$FILE_NAME.rsp";
        chomp $RSP;

        my $CMD_REPLACE_0 = "perl -pi.back -e 's{<dbname>}{$FILE_NAME}g;' $RSP";
        `$CMD_REPLACE_0`;

        print "Enter your desired database configuration\n";
        print "Database Version 11g|12c \n";
        our $DB_VERSION = <STDIN>;
        chomp $DB_VERSION;


        if ($DB_VERSION eq "11g" )
        {
                my $CMD_REPLACE_1 = "perl -pi.back -e 's{<version>}{11.2.0}g;' $RSP";
                `$CMD_REPLACE_1`;
                print "the version you have chosen is 11g \n";
        }
        elsif ($DB_VERSION eq "12c")
        {
                my $CMD_REPLACE_2 = "perl -pi.back -e 's{<version>}{12.1.0}g;' $RSP";
                print "You have chosen 12c \n";
                `$CMD_REPLACE_2`;
        }
        else
        {
                print "that version is not valid my son!";
        }
        print "SGA size in MB:\n";
        our $SGA_SIZE = <STDIN>;
        chomp $SGA_SIZE;
        our  $CMD_REPLACE_3 = "perl -pi.back -e 's{<SGA>}{$SGA_SIZE}g;' $RSP";
        `$CMD_REPLACE_3`;

        print "Set System Password as \n";
        our $SYSPASS = <STDIN>;
        chomp $SYSPASS;
        our  $CMD_REPLACE_4 = "perl -pi.back -e 's{<password>}{$SYSPASS}g;' $RSP";
        `$CMD_REPLACE_4`;


}
else
{
print "You have exceeded the designated instance_name in Oracle";
exit ();

}


our $CMD_DELETE = "rm  /oracle/scripts/A_DBCA/instance_list/*.back";
`$CMD_DELETE`;

#================================================================================================================
#Invoke Oracle Silent DBCA                                                                                      |
#================================================================================================================
our $CURRENT_RSP = "$TARGET_DEST$FILE_NAME.rsp";
our $CMD_DBCA = "$ORACLE_HOME/bin/dbca -silent -responseFile $CURRENT_RSP -continueOnNonFatalErrors true";

system ($CMD_DBCA);



 
