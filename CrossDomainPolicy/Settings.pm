package Plugins::CrossDomainPolicy::Settings;

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
use base qw(Slim::Web::Settings);

use Slim::Utils::Prefs;

my $prefs = preferences('plugin.crossdomainpolicy');

sub name {
	return Slim::Web::HTTP::CSRF->protectName('PLUGIN_XDOMPOL_MODULE_NAME');
}

sub page {
	return Slim::Web::HTTP::CSRF->protectURI('plugins/CrossDomainPolicy/settings/basic.html');
}

sub handler {
	my ($class, $client, $params) = @_;

	if ($params->{'saveSettings'} && $params->{'pref_allowed_domains'}) {
		# skip blank lines
		# TODO: probably a much easier way to do this, but perl makes me
		#       rage.
		my $allowed_domains = $params->{'pref_allowed_domains'};
		my @allowed_domains_list = split(/\n/, $allowed_domains);
		
		my @allowed_domains_cleaned_list;
		foreach (@allowed_domains_list) {
			# strip any whitespace on the line
			my $domain = $_;
			$domain =~ s/^\s*([^\s]*)\s*$/$1/;
			
			if (length($domain) > 0) {
				push @allowed_domains_cleaned_list, $domain;
			}
		}
		
		my $allowed_domains_cleaned = join("\n", @allowed_domains_cleaned_list);
		
		$prefs->set('allowed_domains', $allowed_domains_cleaned);
	}

	$params->{'prefs'}->{'pref_allowed_domains'} = $prefs->get('allowed_domains');

	return $class->SUPER::handler($client, $params);
}

1;

__END__
