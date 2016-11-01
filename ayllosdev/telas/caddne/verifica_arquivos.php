<?php
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/*************************************************************************
	  Fonte: verifica_arquivos.php                                               
	  Autor: Henrique / Jorge                                                 
	  Data : Agosto/2011                       Última Alteração: 13/08/2015
	                                                                   
	  Objetivo  : Copiar os arquivos do correios.
	                                                                 
	  Alterações: 13/08/2015 - Remover o caminho fixo. (James)
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'T')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$msgErro  = 'showError("inform","Importa&ccedil;&atilde;o cancelada!","Alerta - Ayllos","");estado_inicial();';

	$diretorio = dirname(__FILE__) ."/arquivos";
	$arquivos = scandir($diretorio);
	
	// Esconder a mensagem  
	echo 'hideMsgAguardo();';
	
	if (count($arquivos) > 2) {
		echo "bloqueiaFundo($('#divTela'));showConfirmacao('Existem arquivos a serem importados, deseja continuar?','Endere&ccedil;os','showMsgAguardo(\"Aguarde, copiando arquivos ...\");setTimeout(\"copia_arquivos();\",100);','".$msgErro."','sim.gif','nao.gif');";
	} else {
		echo "showMsgAguardo('Aguarde, copiando arquivos ...');setTimeout('copia_arquivos();',100);";
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("inform","'.$msgErro.'","Alerta - Ayllos","");';
		echo 'estado_inicial();';
		exit();
	}
	
?>