<?
/*!
 * FONTE        : retorna_ct.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Junho/2014
 * OBJETIVO     : Gera uma chave de trabalho
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
//	require_once('../../../includes/controla_secao.php');	
	
	$sWorkingKey = strtoupper(substr(md5(dechex(rand())),0,32));
	if (strlen($sWorkingKey) != 32){		
		echo '{"bErro":"1","retorno":"Erro ao gerar Working Key"}';
	}else{
		echo '{"bErro":"0","retorno":"'.$sWorkingKey.'"}';
	}
	
?>