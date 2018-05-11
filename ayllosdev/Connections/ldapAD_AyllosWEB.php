<?php

/**
 ** Conecoes com LDAP (ActiveDirectory)
 **/

// PRODUÇÃO
$srv_ldapAD = array('ldaps://0302dc01.cecred.coop.br','ldaps://0302dc02.cecred.coop.br','ldaps://0303dc01.cecred.coop.br','ldaps://0303dc02.cecred.coop.br');
$dnAD       = 'DC=cecred,DC=coop,DC=br';

// HOMOLOGAÇÃO
// $srv_ldapAD = array('ldaps://0303dchml01');
// $dnAD       = 'DC=cecred,DC=local';

$ldapAD = false;

/* 
   Objetivo: Forma randomica de selecionar os servidores de autenticação
   Data    : 26/05/2011
   Autor   : Rodrigo Supero
*/
$count = 0;
while ($ldapAD==false && $count < count($srv_ldapAD)) {
	$ip   = $srv_ldapAD[array_rand($srv_ldapAD)];
	$port = ereg('ldaps:', $ip) ? '636':'389'; //ldap:389 ou ldaps:636
	$dsAD = ldap_connect($ip, $port);
	//configuracoes
	ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
	ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
	//autentica
	$ldapAD = @ldap_bind($dsAD,"supero","Sup&r0!11");	
	$count++;	
}

if (!$ldapAD) {
	echo 'Erro ao conectar com o AD';
	exit;
}