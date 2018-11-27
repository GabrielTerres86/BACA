<?php  
	/*********************************************************************
	 Fonte: form_filtro.php                                                 
	 Autor: Jonata - Mouts
	 Data : Setembro/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa - CADGRP.                                  
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	switch ($cddopcao) {
		case 'C':
			include("form_filtro_consulta_detalhada.php");
			break;
		default:
			include("form_filtro_busca_grupo.php");
			break;
	}
?>
	




