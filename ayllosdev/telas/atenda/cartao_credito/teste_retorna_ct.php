<?
/*!
 * FONTE        : retorna_ct.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : Junho/2014
 * OBJETIVO     : Gera uma chave de trabalho
 * --------------
 * ALTERA��ES   :
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