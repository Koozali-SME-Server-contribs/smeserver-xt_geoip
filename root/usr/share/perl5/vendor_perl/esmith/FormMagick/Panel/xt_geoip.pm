#!/usr/bin/perl -w

#-------------------------------------------
# Copyright (c) Michel Begue 2017
# Xt_GeoIP Administration panel
#-------------------------------------------
package esmith::FormMagick::Panel::xt_geoip;

use strict;
#use warnings;
use esmith::FormMagick;
use esmith::ConfigDB;
use esmith::util;
use esmith::cgi;
use File::Basename;
use Exporter;
use POSIX qw(strftime);

our @ISA = qw(esmith::FormMagick Exporter);

our @EXPORT = qw(
    otherServices
    do_otherServices
    get_prop
    get_value
    get_badcountries
    get_geoip
    get_stat_license_key
    get_reverse
    print_service_table
    get_stat_geoip
    print_custom_button
    generateStats
    get_srv_name
    get_srv_badcountries
    remove_serv
    modify_serv
    srv_must_exist
    get_date_update
    change_settings
    must_exist
);

our $VERSION = sprintf '%d.%03d', q$Revision: 1.1 $ =~ /: (\d+).(\d+)/;

our $db = esmith::ConfigDB->open || die "Couldn't open ConfigDB\n";

=pod

=head1 NAME

esmith::FormMagick::Panels::xt_geoip - Panel providing countries codes,
enable and update base actions.

=head1 SYNOPSYS

    use esmith::FormMagick::Panel::xt_geoip;

    my $panel = esmith::FormMagick::Panel::xt_geoip->new;
    $panel->display();

=head1 DESCRIPTION

xt_geoip (xtables-addons geoip) install a base of IPs by country.
 This panel provides a 'non-commandline' form to enter selected countries codes
for filtering, to enable-disable the fonctionnality and update the base of IPs.


=cut

# {{{ new

=head2 new()

Exactly as for esmith::FormMagick

=begin testing

$ENV{ESMITH_CONFIG_DB} = "10e-smith-base/configuration.conf"

use_ok('esmith::FormMagick::Panel::xt_geoip');
use vars qw($panel);
ok($panel = esmith::FormMagick::Panel::xt_geoip->new(), "Create panel object");
isa_ok($panel, 'esmith::FormMagick::Panel::xt_geoip');

=end testing

=cut



sub new
{
        shift;
        my $self = esmith::FormMagick->new();
        $self->{calling_package} = (caller)[0];
        bless $self;
#   $self->debug(1);
    return $self;
}

=head2 get_prop

=cut

sub get_prop
{
    my $fm = shift if (ref($_[0]) );
    my $item = shift;
    my $prop = shift;
    
    my $record = $db->get($item);
    if ($record) {
        return $record->prop($prop);
    }
    else {
        return '';
    }
}

=head2 get_value

=cut

sub get_value
{
    my $fm = shift;
    my $item = shift;
    my $record = $db->get($item);
    #return ($db->get("masq")->prop($item));
    if ($record) {
        return $record->value();
    }
    else {
        return '';
    }
}
    
=head2 get_badcountries

method to retrieve the value of "badcountries" for the form
=cut

sub get_badcountries
{
    my $self = shift;
    my $full = shift;
    my $badc=$db->get_prop("masq", "BadCountries")||"";
    return $badc unless $full ;
    my $rev = (($db->get_prop("masq", "XTGeoipRev")||"disabled") eq "enabled") ? "!=" : "==";
    return "$rev $badc ";
}
    
=head2 get_geoip

method to retrieve the value of geoip for the form
=cut

sub get_geoip
{
        return $db->get_prop("masq", "GeoIP") || 'disabled';
}

=head2 get_reverse

method to retrieve the value of geoip for the form
=cut

sub get_reverse
{
    my $fm   = shift;
    my $item = shift;
    my $prop = shift;
    $item = ($item eq 'masq') ? $item : $fm->cgi->param('name');  
        return $db->get_prop("$item", "$prop") || "disabled";
}


=head2 get_stat_geoip

method to retrieve the status of geoip (module and filtering) for the form
=cut

sub get_stat_geoip
{
    my $fm = shift;
    if ( system ( "/bin/test -f /lib/modules/`/bin/uname -r`/weak-updates/xtables-addons/xt_geoip.ko") != 0 ) {
        return $fm->localise('ERROR_MISSING_MODULE');
    } elsif ( system ( "/sbin/lsmod | grep 'xt_geoip' > /dev/null") != 0 ) {
        return $fm->localise('ERROR_UNLOADED_MODULE');
    } elsif ( get_geoip() eq 'enabled' && system ( "/sbin/iptables -L -n | grep 'XTGeoIP' > /dev/null") != 0 ) {
        return $fm->localise('ERROR_FILTER_CHAIN_MISSING');
    } else {
        return '';
    }
}


=head2 get_stat_license_key

method to retrieve the status of geoip license_key for the site
=cut

sub get_stat_license_key {

    my $fm = shift;
    if ((get_prop( 'geoip','status' ) || 'disabled') eq 'enabled' ) {
    if ( (get_prop( 'geoip','LicenseKey' ) || '') ne '' ) {
        return '';
    }
    }
    return $fm->localise('ERROR_LICENSE_KEY');

}


=head2 get_date_update
=cut

sub get_date_update
{
    my $file = "/usr/share/xt_geoip/LE/A1.iv4";
    my $filetime = ( -e $file ) ? (stat($file))[9]  : 0;
    return strftime("%Y/%m/%d %H:%M", localtime( $filetime )) || '';
}

=head2 change_settings

Sub to change settings as per user input in the panel
=cut

sub change_settings
{
    my $self = shift;
    my $q = $self->{'cgi'};
    
    my $mq_bc = get_badcountries();
    my $mq_gp = get_geoip();
    my $masq = $db->get('masq') ||  "disabled";
    my $mq_rv = $masq->prop('XTGeoipRev') || 'disabled';
    my $mq_ot = $masq->prop('XTGeoipOther') || 'disabled';

    my $n_mq_bc = $q->param("masq_badcountries");
    my $n_mq_gp = $q->param("masq_geoip") || $mq_gp;
    my $n_upd_gp = $q->param("update_geoip") || '';
        my $n_mq_rv = $q->param("masq_reverse") || $mq_rv ;
    my $n_mq_ot = $q->param("masq_others") || $mq_ot ;  

    if (($n_mq_bc eq $mq_bc) && ($n_mq_gp eq $mq_gp) && ($n_upd_gp eq 'NO') && ($n_mq_rv eq $mq_rv) && ($n_mq_ot eq $mq_ot)) {
        return $self->success("NO_CHANGE")
    }
    $db->set_prop("masq", "BadCountries", $n_mq_bc);
    $db->set_prop("masq", "GeoIP", $n_mq_gp);
        $db->set_prop("masq", "XTGeoipRev", $n_mq_rv);
    $db->set_prop("masq", "XTGeoipOther", $n_mq_ot);

    my $eventloc = "xt_geoip-modify";
    $eventloc = "xt_geoip-update" if $n_upd_gp eq 'YES';
    
        unless ( system ( "/sbin/e-smith/signal-event",  $eventloc ) == 0 )
    {
        $self->error("ERROR_UPDATING");
        return undef;
        }
    return $self->success("SUCCESS");
}


=head2 valid_badcountries

subroutine to validate countries.
=cut

sub must_exist
{
    my $self = shift;
    my $q = $self->{cgi};
    my $listerr = "";
    my @mq_bcs = split /[,:]/, $q->param("masq_badcountries");
    if (@mq_bcs) {
    my $ctr = @mq_bcs;
    return $self->localise('ERROR_COUNTRY_MAX: {$ctr}', {ctr=> "$ctr"}) if ($ctr > 50);

    foreach my $bcs (@mq_bcs) {
        my $file = "/usr/share/xt_geoip/LE/" . $bcs . ".iv4";
        if (! -f $file)  { $listerr .= $bcs . ","; }
    }
    return $self->localise('ERR_COUNTRY_NOT_EXIST: {$listerr}', {listerr=> "$listerr"}) if $listerr;
    }
    return 'OK';
}

#Subroutine to display buttons
sub print_custom_button
{
    my ($fm,$desc,$url,$type) = @_;
    my $q = $fm->{cgi};
    $url="xt_geoip?page=0&page_stack=&Next=Next&type=".$type."&wherenext=".$url;
    print "  <tr>\n    <td colspan='2'>\n";
    print $q->p($q->a({href => $url, -class => "button-like"},$fm->localise($desc)));
    print qq(</tr>\n);
    return undef;
}

#Subroutine to list statistics
sub generateStats
{
    my $self = shift;
    my $q = $self->{cgi};

    $self->turn_off_buttons();

        # Untaint $name before use in system()
    my $stats_type = $q->param ('type');
        $stats_type =~ /(.+)/; $stats_type = $1;
    if ($stats_type ne "ipt" && $stats_type ne "ssh" && $stats_type ne "f2b")
    {
        print $q->p($q->b($self->localise('INVALID_STATS_TYPE')." ".
            $stats_type));
        return '';
    } else  {
    # my $now_string = $self->gen_locale_date_string();
    my $file = "/var/lib/xt_geoip/extA_" . $stats_type . "_country.lst";
    my $filetime = ( -e $file ) ? (stat($file))[9]  : 0;
    my $date_string = strftime("%Y/%m/%d %H:%M", localtime( $filetime )) || '';
    print $q->h3($self->localise('STATS_GENERATED'), "[", $stats_type, "]", $date_string);

    open( XTGEOIPSTATS, $file );
    print "<pre>\n";

    while (<XTGEOIPSTATS>)
    {
        print;
    }

    close XTGEOIPSTATS;
    print "</pre>\n";

    print $q->h3($self->localise('END_OF_STATS'));
    #$self->wherenext('First');
    return '';
    }
}

sub get_srv_name
{
    my ($self) = @_;
    return $self->cgi->param('name');
}

sub get_srv_badcountries
{
    my $self = shift;
    my $name = $self->cgi->param('name');
    my $full = shift;
    my $badc=$db->get_prop($name, "BadCountries")||"";
    return $badc unless $full ;
    my $rev = (($db->get_prop($name, "XTGeoipRev")||"disabled") eq "enabled") ? "!=" : "==";
    return "$rev $badc ";
}

sub print_service_table {
    my $self = shift;
    my $q = $self->{cgi};
    my $servname        = $self->localise('NAME');
    my $port    = $self->localise('PORT');
    my $status  = $self->localise('STATUS');
    my $access  = $self->localise('ACCESS');
    my $servBC  = $self->localise('BADCOUNTRIES');
    my $modify      = $self->localise('MODIFY');
    my $remove      = $self->localise('REMOVE');
    my $action_h    = $self->localise('ACTION');

    my @services = split(/,/, $db->get_prop("masq", "XtServices"));
    #my @services = ('imaps','pop3s','sshd','ftp','ssmtpd');

    unless ( scalar @services )
    {
        print $q->Tr($q->td($self->localise('NO_SERVICES')));
        return "";
    }

    print $q->start_table({-CLASS => "sme-border"}),"\n";
    print $q->Tr (
                  esmith::cgi::genSmallCell($q, $servname,"header"),
                  esmith::cgi::genSmallCell($q, $port,"header"),
                  esmith::cgi::genSmallCell($q, $status,"header"),
                  esmith::cgi::genSmallCell($q, $access,"header"),
                  esmith::cgi::genSmallCell($q, $servBC,"header"),
                  esmith::cgi::genSmallCell($q, $action_h,"header", 2)),"\n";

    my $scriptname = basename($0);

    foreach my $servname (@services) 
    {
    my $i = $db->get($servname);
    next if not defined $i;

        my $port = $i->prop('TCPPort');
        my $status = $i->prop('status');
        my $access = $i->prop('access');
        my $servBC = $i->prop('BadCountries') || ' ';
    my $servRev = (( $i->prop('XTGeoipRev')|| 'disabled') eq 'disabled' )? '==': '!=';

        my $params = $self->build_serv_cgi_params($servname, $i->props());

        my $href = "$scriptname?$params&action=modify&wherenext=";

        my $actionModify = '&nbsp;';
    $actionModify .= $q->a({href => "${href}SrvModify"},$modify)
          . '&nbsp;';

        my $actionRemove = '&nbsp;';
            $actionRemove .= $q->a({href => "${href}SrvRemove"}, $remove) 
                  . '&nbsp';

    my $color = 'red';
    my $deco= "none";
    if ($servRev eq '!=' ) { $color = 'green'; }
        if ($status eq 'disabled' || $access ne 'public') { $color = 'grey'; $deco= "line-through"; }
        print $q->Tr (
            esmith::cgi::genSmallCell($q, $servname,"normal"),
            esmith::cgi::genSmallCell($q, $port,"normal"),
            esmith::cgi::genSmallCell($q, $status,"normal"),
            esmith::cgi::genSmallCell($q, $access,"normal"),
            esmith::cgi::genSmallCell($q, "<font color='$color' style='text-decoration: $deco'>" . "$servRev $servBC" . "</font>","normal"),
            esmith::cgi::genSmallCell($q, $actionModify,"normal"),
            esmith::cgi::genSmallCell($q, $actionRemove,"normal"));
    }

    print $q->end_table,"\n";

    return "";
}

sub build_serv_cgi_params {
    my ($self, $servname, %oldprops) = @_;

    my %props = (
        page    => 0,
        page_stack => "",
        name => $servname,
    );

    return $self->props_to_query_string(\%props);
}

sub remove_serv {
    my ($self) = @_;
    my $name = $self->cgi->param('name');
    if (my $serv = $db->get($name)) {
    my $servBC = $serv->prop('BadCountries') || '';
        if ($servBC ne '') {
        my $tps = $db->set_prop_and_delete($name, "BadCountries");
            $tps = $db->get_prop_and_delete($name, "XTGeoipRev");
            # Untaint $name before use in system()
            # $name =~ /(.+)/; $name = $1;
            if (system ("/sbin/e-smith/signal-event", "xt_geoip-service") == 0) 
            {
                return $self->success("SUCCESSFULLY_DELETED_SERVICE");
            } else {
                return $self->error("ERROR_WHILE_DELETING_SERVICE");
            }
        } else {
            return $self->success('NO_CHANGE');
        }

    } else {
        $self->error('CANT_FIND_SERV');
    }
    $self->wherenext('First');
}

sub modify_serv {
    my ($self) = @_;
    my $name = $self->cgi->param('name');
    if (my $serv = $db->get($name)) {
    my $servBC = $serv->prop('BadCountries') || '';
        my $servRev = $serv->prop('XTGeoipRev') || 'disabled';

    my $q = $self->{'cgi'};
    my $n_servBC = $q->param("masq_srv_badcountries");
    my $n_servRev = $q->param("masq_srv_reverse") || $servRev;

    if ($n_servBC eq $servBC && $n_servRev eq  $servRev ) {
        return $self->success("NO_CHANGE")
    }
    $db->set_prop($name, "BadCountries", $n_servBC);
    $db->set_prop($name, "XTGeoipRev", $n_servRev);

        if (system ( "/sbin/e-smith/signal-event",  "xt_geoip-service" ) == 0 )
    {
        return $self->success("SUCCESS");
        } else {
        return $self->error("ERROR_UPDATING");
        }
    } else {    
        $self->error('CANT_FIND_SERV');
    }
    $self->wherenext('First');
}

sub srv_must_exist
{
    my $self = shift;
    my $q = $self->{cgi};
    my $listerr = "";
    my @mq_bcs = split /[,:]/, $q->param("masq_srv_badcountries");
    if (@mq_bcs) {
    my $ctr = @mq_bcs;
    return $self->localise('ERROR_COUNTRY_MAX: {$ctr}', {ctr=> "$ctr"}) if ($ctr > 50);

    foreach my $bcs (@mq_bcs) {
        my $file = "/usr/share/xt_geoip/LE/" . $bcs . ".iv4";
        if (! -f $file)  { $listerr .= $bcs . ","; }
    }
    return $self->localise('ERR_COUNTRY_NOT_EXIST: {$listerr}', {listerr=> "$listerr"}) if $listerr;
    }
    return 'OK';
}


#Subroutine to list counries codes
sub generateCodes
{
    my $self = shift;
    my $q = $self->{cgi};

    $self->turn_off_buttons();

    my $file = "/usr/share/xt_geoip/geoip_countries_list.txt";
    unless ( -e $file ) {
        print $q->p($q->b($self->localise('INVALID_CODES_LIST')));
        return '';
    }

    print $q->h3($self->localise('COUNTRY_LIST'));

    open( XTGEOIPCODES, $file );
    print "<pre>\n";

    while (<XTGEOIPCODES>)
    {
        print;
    }

    close XTGEOIPCODES;
    print "</pre>\n";

    print $q->h3($self->localise('END_OF_CODES'));
    return '';

}


#Subroutine to list other services codes
sub otherServices
{
    my ($self, $choice) = @_;

    my %serv_ok = map { $_ => 1} split(/,/, $db->get_prop("masq", "XtServices"));
    # unless $choice eq 'all';

    my @serv_others = ();
    
        for ($db->get_all_by_prop(type => 'service'))
        {
            next unless $_->prop('TCPPort');
        #    if ( $_->prop('TCPPort')) {

        #   push @serv_others, $_->key unless exists( $serv_ok{$_->key});
        push @serv_others, $_->key unless $choice eq 'sel' and not exists( $serv_ok{$_->key});
        #    }
    }

    return \@serv_others;

}


#Subroutine to update list services codes
sub do_otherServices
{
    my $self = shift;

    my $q = $self->{'cgi'};

    my @selected = $q->param('SelectedServices');

    my $serv1 = ($db->get_prop("masq", "XtServices")) || '';
    my $serv2 = join( ',', @selected);

    $self->wherenext('First');

    return $self->success("NO_CHANGE") if ( $serv1 eq $serv2);

    $db->set_prop("masq", "XtServices", $serv2);

    return $self->success("SUCCESS");
}


1;
