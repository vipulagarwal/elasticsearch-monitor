#!/usr/bin/env perl 

# Elastic Search monitor script - Version 1.0
# This script can be used in mon service level monitoring
# Copyright (C) 2013 Vipul Agarwal - vipul@nuttygeeks.com
#
# For latest update, please check the github repository
# available at https://github.com/toxboi/elasticsearch-monitor
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use utf8;
use LWP::Simple;
use LWP::UserAgent;

my $host = $ARGV[0];

# Assert for search results to make sure search is actually working.
# You can change $query_url and $post_data according to your ES search index mapping
my $query_url = "http://$host:9200/gorkana/journalist/_search";
my $post_data = "{ \"fields\" : [\"name\"], \"query\": { \"filtered\" : { \"query\" : { \"ids\": { \"values\": [ 15737 ] } } } } }";

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(POST => $query_url);

$req->content($post_data);
my $resp = $ua->request($req);

if ($resp->is_success) {
	my $message = $resp->decoded_content;
	# Replace string with your expected result
	if (index($message, 'Harry Wallop') == -1) {
		print "Failed to get correct result upon running search query on ES";
		exit 1;
	}
}
else {
	print "Failed to query ES";	
	exit 1;
}

# Check for cluster health
my $health_url = "http://$host:9200/_cluster/health";
my $response = get $health_url;

if ($@) {
	print "Cannot connect to ES server";
	exit 1;
}

my $health = index($response,'green');

if ($health == -1) {
	print "ElasticSearch health degraded";
	exit 1;
}

exit 0;
