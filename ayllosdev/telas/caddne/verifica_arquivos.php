<?php

	/*************************************************************************
	  Fonte: verifica_arquivos.php                                               
	  Autor: Henrique / Jorge                                                 
	  Data : Agosto/2011                       кltima Alteraчуo: 		   
	                                                                   
	  Objetivo  : Copiar os arquivos do correios.
	                                                                 
	  Alteraчѕes: 										   			  
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variсveis globais de controle, e biblioteca de funчѕes	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo mщtodo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'T')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$msgErro  = 'showError("inform","Importa&ccedil;&atilde;o cancelada!","Alerta - Ayllos","");estado_inicial();';

	$diretorio = "/var/www/ayllos/telas/caddne/arquivos";
	$arquivos = scandir($diretorio);
	
	// Esconder a mensagem  
	echo 'hideMsgAguardo();';
	
	if (count($arquivos) > 2) {
		echo "bloqueiaFundo($('#divTela'));showConfirmacao('Existem arquivos a serem importados, deseja continuar?','Endere&ccedil;os','showMsgAguardo(\"Aguarde, copiando arquivos ...\");setTimeout(\"copia_arquivos();\",100);','".$msgErro."','sim.gif','nao.gif');";
	} else {
		echo "showMsgAguardo('Aguarde, copiando arquivos ...');setTimeout('copia_arquivos();',100);";
	}
	
	// Funчуo para exibir erros na tela atravщs de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("inform","'.$msgErro.'","Alerta - Ayllos","");';
		echo 'estado_inicial();';
		exit();
	}
	
?>