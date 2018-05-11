<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 24/03/2017
 * OBJETIVO     : Rotina para os dados
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	require_once("form_prmpos.php");
?>