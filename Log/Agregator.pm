package Log::Agregator;
use Data::Dumper;
use strict;

sub new {
	my ($inClassName) = @_;
	my $this = {
		'messages' => undef,
		'sequence' => []
	};
	
	bless($this, $inClassName);
}

sub setMessages {
	my ($this, $inMessages) = @_;
	
	$this->{'messages'} = $inMessages;
}

sub getSequence {
	my ($this) = @_;
	
	return $this->{'sequence'};
}

sub agregate {
	my ($this, $inRequestId) = @_;
	my $messages = $this->__filterOnRequestId($inRequestId);
	my $req      = undef;
	my $new      = 1;
	my @reqs     = ();
	
	$this->{'sequence'} = [];
	$req = $this->__findBegining($messages);
	return 0 unless (defined($req));
	
	while (1) {
		my $response = undef;
		my $nextReq  = undef;
		
		
		push(@reqs, $req);
		
		# print "REQ:\n";
		# foreach my $r (@reqs) {
		#	print "  - " . messageToString($r, 1) . "\n";
		# }
		
		if ($new) {
			push(@{$this->{'sequence'}}, $req);
			# print messageToString($req) . "\n\n";
		}
		
		$nextReq = $this->__findRequest($messages, $req->{'data'}->{'request-id'});
		
		if (defined($nextReq)) {
			# On a trouvé une requête qui a pour origine la requête courante.
			$req = $nextReq;
			$new = 1;
			next;
		}
		
		# On n'a pas trouvé de requête qui a pour origine la requête courante.
		# On cherche donc une réponse à la requête courante.
		# <=> une réponse qui a pour origine l'origine de la requête courante,
		#     et pour identifiant de la requête celui de la requête courante.
		# print "Looking for a response with:\n";
		# print "  - origin     = " . $req->{'previous-request-id'} . "\n";
		# print "  - request ID = " . $req->{data}->{'request-id'} . "\n";
		$response = $this->__findResponse($messages, $req->{'previous-request-id'}, $req->{'data'}->{'request-id'});
		
		# On devrait trouver une réponse.
		unless (defined($response)) {
			# print "Did not find response for request:\n";
			# print messageToString($req) . "\n\n";
			return 0;
		}
		
		# print messageToString($response) . "\n\n";
		
		push(@{$this->{'sequence'}}, $response);
		
		# print "Deleting request:\n";
		# print messageToString($req) . "\n\n";
		# print "----> " . int();
		$this->__deleteMessage($messages, $req);
		$this->__deleteMessage($messages, $response);
		pop(@reqs);
		
		# On va rechercher la réponse à la requête précédente.
		if (int(@reqs) > 0) {
			$req = $reqs[int(@reqs)-1];
			$new = 0;
			pop(@reqs);
			# print "--- (" . int(@reqs) . ") Next request will be: ";
			# print messageToString($req, 1) . "\n\n";
			next;
		} 
		
		# On recheche la prochaine requête "de début".
		# print "Search for new begining\n";
		$req = $this->__findBegining($messages);
		last unless(defined($req));
		$new = 1;
		
		# print "--- Next begining is: ";
		# print messageToString($req, 1) . "\n\n";		
	}
	return 1;
}

# [PRIVATE] This method returns the messages that are associated to a given request ID.
# + $inRequestId [string] the request ID.
# The methode returns a reference to an array of messages.
sub __filterOnRequestId {
	my ($this, $inRequestId) = @_;
	my @messages = ();
	
	foreach my $message (@{$this->{'messages'}}) {
		next if (($message->{'request-id'} ne $inRequestId));
		next if ($message->{'type'} ne 'REQ' && $message->{'type'} ne 'RES');
		push(@messages, $message);
	}
	
	return \@messages;
}

# [PRIVATE] This method finds the first messages in a given list of messages.
# + $inMessages [array ref] list of messages.
# If a message is found, then the method returns a reference to the first message.
# Otherwize, the method returns the value undef.
sub __findBegining {
	my ($this, $inMessages) = @_;
	my @starts = ();
	
	foreach my $message (@{$inMessages}) {
		if ($message->{'previous-request-id'} eq '-' && $message->{'type'} eq 'REQ') {
			push(@starts, $message);
		}
	}
	@starts = sort { $a->{'rank'} cmp $b->{'rank'} } @starts;
	return undef if (0 == int(@starts));
	return shift(@starts);
}

# [PRIVATE] This method search for a request associated with a given previous request ID.
# + $inMessages [array ref] list of messages.
# + $inPrevReqId [string] previous request ID.
# If a request is found, then the method returns a reference to the request.
# Otherwize, the method returns the value undef.
sub __findRequest {
	my ($this, $inMessages, $inPrevReqId) = @_;
	
	foreach my $message (@{$inMessages}) {
		if ($message->{'previous-request-id'} eq $inPrevReqId && $message->{'type'} eq 'REQ') {
			return $message;
		}
	}	
	return undef;
}

# [PRIVATE] This method search for a response associated with a given "previous request ID" and a given "request ID".
# + $inMessages [array ref] list of messages.
# + $inPrevReqId [string] previous request ID.
# + $inReqId [string] request ID.
# If a response is found, then the method returns a reference to the response.
# Otherwize, the method returns the value undef.
sub __findResponse {
	my ($this, $inMessages, $inPrevReqId, $inReqId) = @_;
	
	foreach my $message (@{$inMessages}) {
		if ($message->{'previous-request-id'} eq $inPrevReqId && $message->{'data'}->{'request-id'} eq $inReqId && $message->{'type'} eq 'RES') {
			return $message;
		}
	}	
	return undef;		
}

# [PRIVATE] This method deletes a given message in a given list of messages.
# + $inMessages [array ref] list of messages.
# + $inMessage [hash ref] the message to delete.
# If the message has been deleted, then the method returns the value 1.
# Otherwize, the method returns the value 0.
sub __deleteMessage {
	my ($this, $inMessages, $inMessage) = @_;
	
	for (my $i=0; $i<int(@{$inMessages}); $i++) {
		if ($inMessages->[$i] == $inMessage) {
			delete $inMessages->[$i];
			return 1;
		}
	}
	return 0;
}

1;