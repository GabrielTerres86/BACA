<?php

/**
 ** Conecoes com LDAP (ActiveDirectory)
 **/

// PRODUÇO
//$srv_ldapAD = array('ldaps://0302dc01.cecred.coop.br','ldaps://0302dc02.cecred.coop.br','ldaps://0303dc01.cecred.coop.br','ldaps://0303dc02.cecred.coop.br');
//$dnAD       = 'DC=cecred,DC=coop,DC=br';

putenv('LDAPTLS_REQCERT=never');

function Conecta_AD ($ip, $port)
{
        $ldapAD = false;
        $iMax = 10;

        for ($i=0; $i < $iMax; $i++){
                $dsAD = ldap_connect($ip, $port);
                echo "$i - $ip : $port - $dsAD ";
                echo(ldap_error($dsAD));

                //configuracoes
                $ldapOpt = ldap_set_option( $dsAD, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
                echo "  OPT PROTOCOL_VERSION= $ldapOpt ";
                echo(ldap_error($dsAD));

                $ldapOpt = ldap_set_option( $dsAD, 8, 0);   // LDAP_OPT_REFERRALS = 0
                echo "  OPT REFERRALS= $ldapOpt ";
                echo(ldap_error($dsAD));

                $ldapTLS = ldap_start_tls($dsAD);
                echo "  TLS= $ldapTLS ";
                echo(ldap_error($dsAD));

                //autentica
                $ldapAD  = ldap_bind($dsAD,"supero","Sup&r0!11");
                echo "  AUTH= $ldapAD ";
                echo(ldap_error($dsAD)."<br>");

                if (!$ldapAD) {
                        $ldapAD  = ldap_bind($dsAD,"supero@cecred.coop.br","Sup&r0!11");
                        echo "  AUTH2= $ldapAD ";
                        echo(ldap_error($dsAD)."<br>");

                        if (!$ldapAD) {
                                echo 'Erro ao conectar com o AD<br>';
                        }
                }

                ldap_close($dsAD);
        }
        echo "<br>";
}

// 0302dc01
Conecta_AD('ldap://0302dc01.cecred.coop.br', 389);

// 0302dc02
Conecta_AD('ldap://0302dc02.cecred.coop.br', 389);

// 0303dc01
Conecta_AD('ldap://0303dc01.cecred.coop.br', 389);

// 0303dc02
Conecta_AD('ldap://0303dc02.cecred.coop.br', 389);

?>

