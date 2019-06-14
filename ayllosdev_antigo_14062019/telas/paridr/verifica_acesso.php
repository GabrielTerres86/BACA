<?php
	/*************************************************************************
	  Fonte: verifica_acesso.php                                               
	  Autor: Lucas Reinert                                          
	  Data : Julho/2015                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Verifica as permissões da tela PARIDR
	                                                                 
	  Alterações: 
				  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	isPostMethod();		
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao, false)) <> '') {		
	   exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}else{
		echo 'trocaVisao("'.$cddopcao.'");';
	}
	
?>