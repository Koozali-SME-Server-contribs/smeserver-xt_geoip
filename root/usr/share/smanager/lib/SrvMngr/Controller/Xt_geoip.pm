package SrvMngr::Controller::Xt_geoip;

#----------------------------------------------------------------------
# heading     : Network
# description : GeoIP IP filtering
# navigation  : 6000 610
# name : xt_geoip,   method : get,  url : /xt_geoip,  ctlact : Xt_geoip#main
# name : xt_geoipd,  method : post, url : /xt_geoip,  ctlact : Xt_geoip#do_display
# name : xt_geoipc,  method : get,  url : /xt_geoipb, ctlact : Xt_geoip#do_display
# name : xt_geoipu,  method : post, url : /xt_geoipb, ctlact : Xt_geoip#do_action
#
# routes : end
#----------------------------------------------------------------------
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use POSIX qw(strftime);
use Locale::gettext;
use SrvMngr::I18N;
use SrvMngr qw( theme_list init_session );

# our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
my ($cdb);

sub main {
    my $c = shift;
    $c->app->log->info($c->log_req);
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $title = $c->render_to_string(inline => ($c->l('xtg_FORM_TITLE')));
    my %xtg_datas = ();
    $xtg_datas{'choice'} = '';
    $c->stash(title => $title, xtg_datas => \%xtg_datas);
    $c->render('xt_geoip');
} ## end sub main

sub do_display {
    my $c = shift;
    $c->app->log->info($c->log_req);
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $title = $c->render_to_string(inline => ($c->l('xtg_FORM_TITLE')));
    my $choice = $c->param('Choice');
    my $result;
    my %xtg_datas = ();
    $xtg_datas{'choice'} = $choice;

    if ($choice eq 'LCOD') {
        $result = $c->generateCodes();

        #        $c->stash( title => $title, modul => $result, xtg_datas => \%xtg_datas );
        #        return $c->render('xt_geoip_lst');
    } ## end if ($choice eq 'LCOD')

    if ($choice eq 'LF2B') {
        $result = $c->generateStats('f2b');

        #        $result = $c->render_to_string(inline => generateStats($c, 'f2b'));
        #        $c->stash( title => $title, modul => $result, xtg_datas => \%xtg_datas );
        #        return $c->render('xt_geoip_lst');
    } ## end if ($choice eq 'LF2B')

    if ($choice eq 'LSSH') {
        $result = $c->generateStats('ssh');

        #        $result = $c->render_to_string(inline => generateStats($c, 'ssh'));
        #        $c->stash( title => $title, modul => $result, xtg_datas => \%xtg_datas );
        #        return $c->render('xt_geoip_lst');
    } ## end if ($choice eq 'LSSH')

    if ($choice eq 'LIPT') {
        $result = $c->generateStats('ipt');

        #        $c->stash( title => $title, modul => $result, xtg_datas => \%xtg_datas );
        #        return $c->render('xt_geoip_lst');
    } ## end if ($choice eq 'LIPT')

    if ($choice eq 'LSRV') {

        #        $c->stash( title => $title, xtg_datas => \%xtg_datas );
        #        return $c->render('xt_geoip_lsrv');
    } ## end if ($choice eq 'LSRV')

    if ($choice eq 'UPDT') {

        #        $c->stash( title => $title, xtg_datas => \%xtg_datas );
        #        return $c->render('xt_geoip_updt');
    } ## end if ($choice eq 'UPDT')

    if ($choice eq 'UPDS') {
        $xtg_datas{name} = $c->param('Name');

        #        $c->stash( title => $title, xtg_datas => \%xtg_datas );
        #        return $c->render('xt_geoip_upds');
    } ## end if ($choice eq 'UPDS')

    if ($choice eq 'REMS') {
        $xtg_datas{name} = $c->param('Name');

        #        $c->stash( title => $title, xtg_datas => \%xtg_datas );
        #        return $c->render('xt_geoip_rems');
    } ## end if ($choice eq 'REMS')
    $c->stash(title => $title, modul => $result, xtg_datas => \%xtg_datas);
    return $c->render('xt_geoip_lst')                 if ($choice ~~ [ 'LCOD', 'LF2B', 'LSSH', 'LIPT' ]);
    return $c->render('xt_geoip' . '_' . lc($choice)) if ($choice ~~ [ 'UPDT', 'UPDS', 'REMS', 'LSRV' ]);
    $c->redirect_to('/xt_geoip');
} ## end sub do_display

sub do_action {
    my $c = shift;
    $c->app->log->info($c->log_req);
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $rt        = $c->current_route;
    my $title     = $c->render_to_string(inline => ($c->l('xtg_FORM_TITLE')));
    my %xtg_datas = ();
    my $choice    = $c->param('Choice');
    $xtg_datas{'choice'} = $choice;
    my ($res, $result) = '';

    if ($choice eq 'LSRV') {

        #$result .= 'Blocked for testing ! Avoid updates for now ';
        $res = '';

        if (!$result) {
            $res = $c->do_otherServices();
            $result .= $res unless $res eq 'OK';

            if (!$result) {
                $result = $c->l('xtg_SERVICE_SUCCESS');
            }
        } ## end if (!$result)
    } ## end if ($choice eq 'LSRV')

    if ($choice eq 'UPDT') {
        $res = $c->must_exist();
        $result .= $res unless $res eq 'OK';

        #$result .= 'Blocked for testing ! Avoid updates for now ';
        $res = '';

        if (!$result) {
            $res = $c->change_settings();
            $result .= $res unless $res eq 'OK';

            if (!$result) {
                $result = $c->l('xtg_SUCCESS');
            }
        } ## end if (!$result)
    } ## end if ($choice eq 'UPDT')

    if ($choice eq 'REMS') {

        #$result .= 'Blocked for testing ! Avoid updates for now ';
        my $name = $c->param('Name');
        $xtg_datas{name} = $name;
        $res = '';

        if (!$result) {
            $res = $c->remove_serv();
            $result .= $res unless $res eq 'OK';

            if (!$result) {
                $result = $c->l('xtg_SUCCESSFULLY_DELETED_SERVICE');
            }
        } ## end if (!$result)
    } ## end if ($choice eq 'REMS')

    if ($choice eq 'UPDS') {

        #$result .= 'Blocked for testing ! Avoid updates for now ';
        my $name = $c->param('Name');
        $xtg_datas{name} = $name;
        $res = '';

        if (!$result) {
            $res = $c->modify_serv();
            $result .= $res unless $res eq 'OK';

            if (!$result) {
                $result = $c->l('xtg_SERVICE_SUCCESS');
            }
        } ## end if (!$result)
    } ## end if ($choice eq 'UPDS')

    # common parts
    if ($res ne 'OK') {
        $c->stash(error => $result);
        $c->stash(title => $title, xtg_datas => \%xtg_datas);
        return $c->render('xt_geoip' . '_' . lc($choice));
    }
    my $message = "xt_geoip updates $choice DONE";
    $c->app->log->info($message);
    $c->flash(success => $result);
##    $c->flash( error => 'No changes applied !!' );
    #return to 'xt_geoip' route !!!
    $c->redirect_to('/xt_geoip');
} ## end sub do_action

sub get_badcountries {
    my $c    = shift;
    my $full = shift;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $badc = $cdb->get_prop("masq", "BadCountries") || "";
    return $badc unless $full;
    my $rev = (($cdb->get_prop("masq", "XTGeoipRev") || "disabled") eq "enabled") ? "!=" : "==";
    return "$rev $badc ";
} ## end sub get_badcountries

sub get_geoip {
    return $cdb->get_prop("masq", "GeoIP") || 'disabled';
}

sub get_reverse {
    my $c    = shift;
    my $item = shift;
    my $prop = shift;
    $item = ($item eq 'masq') ? $item : $c->param('Name');
    return $cdb->get_prop("$item", "$prop") || "disabled";
} ## end sub get_reverse

sub get_stat_geoip {
    my $c = shift;

    if (system("/bin/test -f /lib/modules/`/bin/uname -r`/weak-updates/xtables-addons/xt_geoip.ko") != 0) {
        return $c->l('xtg_ERROR_MISSING_MODULE');
    } elsif (system("/sbin/lsmod | grep 'xt_geoip' > /dev/null") != 0) {
        return $c->l('xtg_ERROR_UNLOADED_MODULE');
    } elsif (get_geoip() eq 'enabled' && system("/sbin/iptables -L -n | grep 'XTGeoIP' > /dev/null") != 0) {
        return $c->l('xtg_ERROR_FILTER_CHAIN_MISSING');
    } else {
        return '';
    }
} ## end sub get_stat_geoip

sub get_stat_license_key {
    my $c = shift;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";

    if (($cdb->get_prop('geoip', 'status') || 'disabled') eq 'enabled') {
        if (($cdb->get_prop('geoip', 'LicenseKey') || '') ne '') {
            return '';
        }
    } ## end if (($cdb->get_prop('geoip'...)))
    return $c->l('xtg_ERROR_LICENSE_KEY');
} ## end sub get_stat_license_key

sub get_date_update {
    #my $file = "/usr/share/xt_geoip/LE/A1.iv4";
    my $file = "/usr/share/xt_geoip/A1.iv4";
    my $filetime = (-e $file) ? (stat($file))[9] : 0;
    return strftime("%Y/%m/%d %H:%M", localtime($filetime)) || '';
} ## end sub get_date_update

sub get_srv_name {
    my ($c) = @_;
    return $c->param('Name');
}

sub get_services_table {
    my $c = shift;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $choice = shift || 'sel';
    my @services;
    my @serv_rec;

    if ($choice ne 'all') {
        @services = split(/,/, $cdb->get_prop("masq", "XtServices"));

        for (@services) {
            my $rec = $cdb->get($_);
            push @serv_rec, $rec if ($rec && $rec->prop('TCPPort'));
        }
    } else {

        for ($cdb->get_all_by_prop(type => 'service')) {
            push @serv_rec, $_ if ($_->prop('TCPPort'));
        }
    } ## end else [ if ($choice ne 'all') ]
    return \@serv_rec;
} ## end sub get_services_table

sub get_srv_badcountries {
    my ($c, $name, $full) = @_;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $badc = $cdb->get_prop($name, "BadCountries") || "";
    return $badc unless $full;
    my $rev = (($cdb->get_prop($name, "XTGeoipRev") || "disabled") eq "enabled") ? "!=" : "==";
    return "$rev $badc ";
} ## end sub get_srv_badcountries

#Subroutine to list statistics
sub generateStats {
    my $c          = shift;
    my $stats_type = shift;
    my $out        = '';

    # Untaint $name before use in system()
    $stats_type =~ /(.+)/;
    $stats_type = $1;

    if ($stats_type ne "ipt" and $stats_type ne "ssh" and $stats_type ne "f2b") {
        $out .= sprintf("<h3>%s %s </h3>", $c->l('xtg_INVALID_STATS_TYPE'), $stats_type);
        return $out;
    }

    # my $now_string = $c->gen_locale_date_string();
    my $file        = "/var/lib/xt_geoip/extA_" . $stats_type . "_country.lst";
    my $filetime    = (-e $file) ? (stat($file))[9] : 0;
    my $date_string = strftime("%Y/%m/%d %H:%M", localtime($filetime)) || '';
    $out .= sprintf("<h3>%s %s %s</h3>", $c->l('xtg_STATS_GENERATED'), $stats_type, $date_string);
    open(Xt_GEOIPSTATS, $file);
    $out .= sprintf "<pre>";

    while (<Xt_GEOIPSTATS>) {
        $out .= sprintf("%s", $_);
    }
    close Xt_GEOIPSTATS;
    $out .= sprintf "</pre>";
    $out .= sprintf("<h3>%s</h3>", $c->l('xtg_END_OF_STATS'));
    return $out;
} ## end sub generateStats

#Subroutine to list countries codes
sub generateCodes {
    my $c   = shift;
    my $out = '';

    # my $now_string = $c->gen_locale_date_string();
    my $file = "/usr/share/xt_geoip/geoip_countries_list.txt";

    unless (-e $file) {
        $out .= "<br>" . $c->l('xtg_INVALID_CODES_LIST');
        return $out;
    }
    my $filetime = (-e $file) ? (stat($file))[9] : 0;
    my $date_string = strftime("%Y/%m/%d %H:%M", localtime($filetime)) || '';
    $out .= sprintf("<h3>%s %s </h3>", $c->l('xtg_COUNTRY_LIST'), $date_string);
    open(Xt_GEOIPCODES, $file);
    $out .= sprintf "<pre>";

    while (<Xt_GEOIPCODES>) {
        $out .= sprintf("%s", $_);
    }
    close Xt_GEOIPCODES;
    $out .= sprintf "</pre>";
    $out .= sprintf("<h3>%s</h3>", $c->l('xtg_END_OF_CODES'));
    return $out;
} ## end sub generateCodes

#Subroutine to list other services codes
sub otherServices {
    my ($c, $choice) = @_;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my %serv_ok = map { $_ => 1 } split(/,/, $cdb->get_prop("masq", "XtServices"));

    # unless $choice eq 'all';
    my @serv_others = ();

    for ($cdb->get_all_by_prop(type => 'service')) {
        next unless $_->prop('TCPPort');

        #    if ( $_->prop('TCPPort')) {
        #	push @serv_others, $_->key unless exists( $serv_ok{$_->key});
        push @serv_others, $_->key unless $choice eq 'sel' and not exists($serv_ok{ $_->key });

        #    }
    } ## end for ($cdb->get_all_by_prop...)
    return \@serv_others;
} ## end sub otherServices

#Subroutine to update list services codes
sub do_otherServices {
    my $c = shift;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $serv1 = ($cdb->get_prop("masq", "XtServices")) || '';
    my $serv2 = join(',', @{ $c->every_param('Selectedservices') });
    $cdb->set_prop("masq", "XtServices", $serv2) if ($serv1 ne $serv2);
    return 'OK';
} ## end sub do_otherServices

sub change_settings {
    my $c = shift;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $mq_bc    = get_badcountries();
    my $mq_gp    = get_geoip();
    my $masq     = $cdb->get('masq') || "disabled";
    my $mq_rv    = $masq->prop('XTGeoipRev') || 'disabled';
    my $mq_ot    = $masq->prop('XTGeoipOther') || 'disabled';
    my $n_mq_bc  = $c->param("Masq_badcountries");
    my $n_mq_gp  = $c->param("Masq_geoip") || $mq_gp;
    my $n_upd_gp = $c->param("Update_geoip") || '';
    my $n_mq_rv  = $c->param("Masq_reverse") || $mq_rv;
    my $n_mq_ot  = $c->param("Masq_others") || $mq_ot;

    if (   ($n_mq_bc eq $mq_bc)
        && ($n_mq_gp eq $mq_gp)
        && ($n_upd_gp eq 'NO')
        && ($n_mq_rv eq $mq_rv)
        && ($n_mq_ot eq $mq_ot))
    {
        return 'OK';
    } ## end if (($n_mq_bc eq $mq_bc...))
    $cdb->set_prop("masq", "BadCountries", $n_mq_bc);
    $cdb->set_prop("masq", "GeoIP",        $n_mq_gp);
    $cdb->set_prop("masq", "XTGeoipRev",   $n_mq_rv);
    $cdb->set_prop("masq", "XTGeoipOther", $n_mq_ot);
    my $eventloc = "xt_geoip-modify";
    $eventloc = "xt_geoip-update" if $n_upd_gp eq 'YES';

    unless (system("/sbin/e-smith/signal-event", $eventloc) == 0) {
        return $c->l("xtg_ERROR_UPDATING");
    }
    return 'OK';
} ## end sub change_settings

=head2 valid_badcountries

subroutine to validate countries.
=cut

sub must_exist {
    my $c       = shift;
    my $listerr = "";
    my @mq_bcs  = split /[,:]/, $c->param("Masq_badcountries");

    if (@mq_bcs) {
        my $ctr = @mq_bcs;
        return $c->l('xtg_ERROR_COUNTRY_MAX', $ctr) if ($ctr > 50);

        foreach my $bcs (@mq_bcs) {
            #my $file = "/usr/share/xt_geoip/LE/" . $bcs . ".iv4";
            my $file = "/usr/share/xt_geoip/" . $bcs . ".iv4";
            if (!-f $file) { $listerr .= $bcs . ","; }
        }
        return $c->l('xtg_ERROR_COUNTRY_NOT_EXIST', $listerr) if $listerr;
    } ## end if (@mq_bcs)
    return 'OK';
} ## end sub must_exist

sub remove_serv {
    my ($c) = @_;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $name = $c->param('Name');

    # Untaint $name before use in system()
    $name =~ /(.+)/;
    $name = $1;

    if (my $serv = $cdb->get($name)) {
        my $servBC = $serv->prop('BadCountries') || '';

        if ($servBC ne '') {
            my $tps = $cdb->get_prop_and_delete($name, "BadCountries");
            $tps = $cdb->get_prop_and_delete($name, "XTGeoipRev");

            unless (system("/sbin/e-smith/signal-event", "xt_geoip-service") == 0) {
                return $c->l("xtg_ERROR_WHILE_DELETING_SERVICE") . ' ' . $name;
            }
            return 'OK';
        } ## end if ($servBC ne '')
    } else {
        return $c->l('xtg_CANT_FIND_SERV');
    }
} ## end sub remove_serv

sub modify_serv {
    my ($c) = @_;
    our $cdb = esmith::ConfigDB->open() or die "Couldn't open ConfigDB\n";
    my $name = $c->param('Name');

    # Untaint $name before use in system()
    $name =~ /(.+)/;
    $name = $1;

    if (my $serv = $cdb->get($name)) {
        my $servBC  = $serv->prop('BadCountries') || '';
        my $servRev = $serv->prop('XTGeoipRev')   || 'disabled';
        my $n_servBC = $c->param("Masq_srv_badcountries");
        my $n_servRev = $c->param("Masq_srv_reverse") || $servRev;

        if ($n_servBC eq $servBC && $n_servRev eq $servRev) {
            return 'OK';
        }
        $cdb->set_prop($name, "BadCountries", $n_servBC);
        $cdb->set_prop($name, "XTGeoipRev",   $n_servRev);

        unless (system("/sbin/e-smith/signal-event", "xt_geoip-service") == 0) {
            return $c->l("xtg_ERROR_UPDATING") . ' ' . $name;
        }
        return 'OK';
    } else {
        return $c->l('xtg_CANT_FIND_SERV');
    }
} ## end sub modify_serv
1;
