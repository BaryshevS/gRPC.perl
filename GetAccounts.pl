#!/bin/env perl

use strict;
use warnings;
use Google::ProtocolBuffers::Dynamic;
use Grpc::XS;
use Grpc::XS::ChannelCredentials;
use Grpc::Constants;
use DDP;
use FindBin qw($Bin);

# https://developers.google.com/protocol-buffers/docs/proto3

#info
my $d = Google::ProtocolBuffers::Dynamic->new($Bin.'/protos');
$d->load_file("users.proto");

# https://metacpan.org/pod/Google::ProtocolBuffers::Dynamic#INTROSPECTION
my $package='Tinkoff::UsersService';
 $d->map({ package => 'tinkoff.public.invest.api.contract.v1', prefix => 'Tinkoff', options => {
   client_services => 'grpc_xs'
 } });

my $credentials = Grpc::XS::ChannelCredentials::createInsecure();
my $stub = Tinkoff::UsersService->new(
  'invest-public-api.tinkoff.ru:443',
  'grpc.primary_user_agent' => 'GoInv.ru',#fix https://github.com/joyrex2001/grpc-perl/pull/24
  # 'grpc.ssl_target_name_override' => $host_override,
  # 'grpc.default_authority' => $host_override,
  metadata=>{
    'authorization' => 'Bearer '.  (exists $ENV{PERSONAL_TOKEN} ? $ENV{PERSONAL_TOKEN} : 'test')
  },
  credentials => $credentials,
  timeout => 1000000
);
print np($stub)."\n";

my $request = Tinkoff::GetAccountsRequest->new({});
print np($request)."\n";

my $call = $stub->GetAccounts( argument => $request );
print np($call)."\n";

my $response = $call->wait;
print np($response)."\n";

if ($response) {
  print $response->get_message;
  # $response->to_hashref()
}else {
  print "error\n";
};