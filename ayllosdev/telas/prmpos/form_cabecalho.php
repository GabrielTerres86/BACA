<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Jaison
 * DATA CRIA��O : 24/03/2017
 * OBJETIVO     : Cabe�alho para a tela
 * --------------
 * ALTERA��ES   : 
 *				  
 * --------------
 */	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>