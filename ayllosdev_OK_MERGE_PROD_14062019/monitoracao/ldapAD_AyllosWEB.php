<?php

/**
 ** Conecoes com LDAP (ActiveDirectory)
 **/
    
require_once("ldapAD_funcoes.php");
	
// PRODUÇÃO
$srv_ldapAD = array('ldaps://0302dc01.cecred.coop.br','ldaps://0302dc02.cecred.coop.br','ldaps://0303dc01.cecred.coop.br','ldaps://0303dc02.cecred.coop.br');
$dnAD       = 'DC=cecred,DC=coop,DC=br';

// HOMOLOGAÇÃO
// $srv_ldapAD = array('ldaps://0303dchml01');
// $dnAD       = 'DC=cecred,DC=local';

$ldapAD = false;

// 0302dc01
$ip   = 'ldaps://0302dc01.cecred.coop.br';
$port = 389; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$ip   = 'ldaps://0302dc01.cecred.coop.br';
$port = 636; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$grupos  = ldapAD_getGrupos($dsAD);

//Exibe informações
for ($i=0; $i < 10/*$grupos["count"]*/; $i++){
	echo "<pre>";	
//	print_r($grupos[$i]);
	print_r($grupos[$i]["name"][0]);
//	print_r($grupos[$i]["description"][0]);
//	print_r($grupos[$i]["member"][0]);
	echo "</pre>";
}

echo "<br>";

// 0302dc02
$ip   = 'ldaps://0302dc02.cecred.coop.br';
$port = 389; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$ip   = 'ldaps://0302dc02.cecred.coop.br';
$port = 636; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$grupos  = ldapAD_getGrupos($dsAD);

//Exibe informações
for ($i=0; $i < 10/*$grupos["count"]*/; $i++){
	echo "<pre>";	
	print_r($grupos[$i]["name"][0]);
	echo "</pre>";
}

echo "<br>";


// 0303dc01
$ip   = 'ldaps://0303dc01.cecred.coop.br';
$port = 389; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$ip   = 'ldaps://0303dc01.cecred.coop.br';
$port = 636; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$grupos  = ldapAD_getGrupos($dsAD);

//Exibe informações
for ($i=0; $i < 10/*$grupos["count"]*/; $i++){
	echo "<pre>";	
	print_r($grupos[$i]["name"][0]);
	echo "</pre>";
}

echo "<br>";


// 0303dc02
$ip   = 'ldaps://0303dc02.cecred.coop.br';
$port = 389; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$ip   = 'ldaps://0303dc02.cecred.coop.br';
$port = 636; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$grupos  = ldapAD_getGrupos($dsAD);

//Exibe informações
for ($i=0; $i < 10/*$grupos["count"]*/; $i++){
	echo "<pre>";	
	print_r($grupos[$i]["name"][0]);
	echo "</pre>";
}

echo "<br>";

/*
// 0303dcmhl01 - Homologação
$ip   = 'ldaps://0303dchml01';
$port = 389; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
}

$ip   = 'ldaps://0303dchml01';
$port = 636; //ldap:389 ou ldaps:636
$dsAD = ldap_connect($ip, $port);
//configuracoes
ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
//autentica
$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");
echo "$ip : $port - $dsAD ldapAD= $ldapAD <br>";
*/
if (!$ldapAD) {
	echo 'Erro ao conectar com o AD<br>';
	exit;
}
