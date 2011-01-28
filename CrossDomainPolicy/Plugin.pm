package Plugins::CrossDomainPolicy::Plugin;

# Cross-Domain Policy Plugin for Squeezebox Server 7.3 and up.
# Samuel Lai, sam@edgylogic.com
# http://edgylogic.com/projects/sbs-crossdomainpolicy
#
# This code has been derived from code with the following copyright message:
#
# Squeezebox Server Copyright 2005-2009 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 2.

use strict;
use base qw(Slim::Plugin::Base);

use Slim::Utils::Log;
use Slim::Utils::Strings qw(string);
use Slim::Utils::Prefs;
use Slim::Player::Sync;
use Slim::Web::HTTP;

if ( main::WEBUI ) {
        require Plugins::CrossDomainPolicy::Settings;
}

my $log = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.crossdomainpolicy',
	'defaultLevel' => 'ERROR',
	'description'  => getDisplayName(),
});

my $prefs = preferences('plugin.crossdomainpolicy');

sub getDisplayName {
	return 'PLUGIN_XDOMPOL_MODULE_NAME';
}

sub initPlugin {
	my ( $class, %args ) = @_;
	
	$class->SUPER::initPlugin();
	
	if ( main::WEBUI ) {
		Plugins::CrossDomainPolicy::Settings->new;
	}
}

sub shutdownPlugin {
	my $class = shift;

	# unsubscribe
	Slim::Control::Request::unsubscribe(\&_libraryChanged);
	
	# remove web menus
	webPages();	
}

sub webPages {
	my $class = shift;
	
	Slim::Web::Pages->addPageFunction("crossdomain.html", \&handlePolicy);
	Slim::Web::Pages->addPageFunction("crossdomain.xml", \&handlePolicy);
}

# Draws the plugin's web page
sub handlePolicy {
	my ( $client, $params, $callback, $httpClient, $response ) = @_;

	my $allowed_domains = $prefs->get('allowed_domains');
	my @allowed_domains_list = split(/\n/, $allowed_domains);
	
	$params->{ 'allowed_domains' } = \@allowed_domains_list;
	
	my $template = 'plugins/CrossDomainPolicy/crossdomain.xml';

	return Slim::Web::HTTP::filltemplatefile( $template, $params );
}

1;

__END__


