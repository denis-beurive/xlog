use strict;
use Log::Agregator;
use Data::Dumper;


my @logs = (
	{
		'timestamp'           => '201411221100',
		'request-id'          => 'action1',
		'rank'                => 0,
		'service-id'          => 'S1',
		'previous-request-id' => '-',
		'environnement-id'    => 'serveur1',
		'type'                => 'REQ',
		'data'                => { 'to' => 'S2', 'request-id' => 'idReq1' }
	},
	{
		'timestamp'           => '201411221101',
		'request-id'          => 'action1',
		'rank'                => 0,
		'service-id'          => 'S2',
		'previous-request-id' => 'idReq1',
		'environnement-id'    => 'serveur1',
		'type'                => 'REQ',
		'data'                => { 'to' => 'S3', 'request-id' => 'idReq2' }
	},
	{
		'timestamp'           => '201411221102',
		'request-id'          => 'action1',
		'service-id'          => 'S3',
		'rank'                => 0,
		'previous-request-id' => 'idReq2',
		'environnement-id'    => 'serveur1',
		'type'                => 'REQ',
		'data'                => { 'to' => 'S4', 'request-id' => 'idReq3' }
	},
	{
		'timestamp'           => '201411221103',
		'request-id'          => 'action1',
		'service-id'          => 'S3',
		'rank'                => 1,
		'previous-request-id' => 'idReq2',
		'environnement-id'    => 'serveur1',
		'type'                => 'RES',
		'data'                => { 'request-id' => 'idReq3', 'status' => 'SUCCESS', 'response' => '' }
	},
	{
		'timestamp'           => '201411221104',
		'request-id'          => 'action1',
		'service-id'          => 'S2',
		'rank'                => 1,
		'previous-request-id' => 'idReq1',
		'environnement-id'    => 'serveur1',
		'type'                => 'RES',
		'data'                => { 'request-id' => 'idReq2', 'status' => 'SUCCESS', 'response' => ''  }
	},	
	{
		'timestamp'           => '201411221104',
		'request-id'          => 'action1',
		'service-id'          => 'S1',
		'rank'                => 1,
		'previous-request-id' => '-',
		'environnement-id'    => 'serveur1',
		'type'                => 'RES',
		'data'                => { 'request-id' => 'idReq1', 'status' => 'SUCCESS', 'response' => ''  }
	},
	{
		'timestamp'           => '201411221105',
		'request-id'          => 'action1',
		'service-id'          => 'S1',
		'rank'                => 2,
		'previous-request-id' => '-',
		'environnement-id'    => 'serveur1',
		'type'                => 'REQ',
		'data'                => { 'to' => 'S5', 'request-id' => 'idReq4' }
	},	
	{
		'timestamp'           => '201411221105',
		'request-id'          => 'action1',
		'service-id'          => 'S5',
		'rank'                => 0,
		'previous-request-id' => 'idReq4',
		'environnement-id'    => 'serveur1',
		'type'                => 'REQ',
		'data'                => { 'to' => 'S2', 'request-id' => 'idReq5' }
	},	
	{
		'timestamp'           => '201411221106',
		'request-id'          => 'action1',
		'service-id'          => 'S5',
		'rank'                => 1,
		'previous-request-id' => 'idReq4',
		'environnement-id'    => 'serveur1',
		'type'                => 'RES',
		'data'                => { 'request-id' => 'idReq5', 'status' => 'SUCCESS', 'response' => ''  }
	},	
	{
		'timestamp'	          => '201411221107',
		'request-id'          => 'action1',
		'service-id'          => 'S1',
		'rank'                => 3,
		'previous-request-id' => '-',
		'environnement-id'    => 'serveur1',
		'type'                => 'RES',
		'data'                => { 'request-id' => 'idReq4', 'status' => 'SUCCESS', 'response' => ''  }
	}	
);



my $logAgregator = Log::Agregator->new();
my $sequence     = undef;

$logAgregator->setMessages(\@logs);
$logAgregator->agregate('action1');
$sequence = $logAgregator->getSequence();

unless(defined($sequence)) {
	print "Agregation error!\n";
	exit(1);
}

print Data::Dumper->Dump($sequence) . "\n";


