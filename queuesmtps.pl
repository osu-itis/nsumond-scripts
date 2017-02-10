#!/usr/bin/perl -w
use strict;
use Net::SMTP;
use Netscaler::KAS;

sub smtps_queue_probe
{
    if(scalar(@_) < 3)
    {
        return (1,"Invalid number of arguments");
    }

    my $smtp;
    my ($from_addr, $to_addr) = split /:/, $_[2];
    $smtp=Net::SMTP->new($_[0].":".$_[1], Timeout=>$_[3], SSL=>1)
        or return (1,"Unable to connect to server - $!");
    $smtp->mail($from_addr)
        or return(2,"MAIL FROM rejected - ".$smtp->message());
    $smtp->recipient($to_addr)
        or return(3,"RCPT TO rejected - ".$smtp->message());
    $smtp->data
        or return(4,"DATA rejected - $!");
    $smtp->datasend("To: $to_addr\n");
    $smtp->datasend("From: $from_addr\n");
    $smtp->datasend("\n");
    $smtp->datasend("This is a test email from a Netscaler probe\n");
    $smtp->dataend
        or return(5,"DATA error - $!");
    $smtp->quit;
    return 0;
}

probe(\&smtps_queue_probe);
