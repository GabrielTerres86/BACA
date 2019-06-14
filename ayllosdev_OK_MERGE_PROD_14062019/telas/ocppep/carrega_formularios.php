<?php

	/*****************************************************************************************************
	  Fonte: carregra_formularios.php                                               
	  Autor: Adriano                                                  
	  Data : Março/2017                       						Última Alteração: 
	                                                                   
	  Objetivo  : Carrega os formularios da tela.
	                                                                 
	  Alterações:
	                                                                  
	*****************************************************************************************************/


	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
		
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');	
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
		
	include('form_subrotinas.php');
																			
	include('form_natureza_ocupacao.php');

	include('form_ocupacao.php');

	include('form_detalhes_ocupacao.php');
		
?>

<script text="text/javascript">

	controlaLayout('1');

</script>


				


				

