<?php 

	/************************************************************************
          Fonte: principal.php
	      Autor: Lucas R.
          Data : Julho/2013                 Ultima Alteracao: 00/00/0000

	      Objetivo  : Listar os consorcios

	      Alteracoes:
              		  
	 ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"])) <> "") {
		exibeErro($msgError);		
	}	

	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];	
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlConsorcio  = "";
	$xmlConsorcio .= "<Root>";
	$xmlConsorcio .= "	<Cabecalho>";
	$xmlConsorcio .= "		<Bo>b1wgen0162.p</Bo>";
	$xmlConsorcio .= "		<Proc>lista_consorcio</Proc>";
	$xmlConsorcio .= "	</Cabecalho>";
	$xmlConsorcio .= "	<Dados>";
	$xmlConsorcio .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsorcio .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsorcio .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlConsorcio .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlConsorcio .= "	</Dados>";
	$xmlConsorcio .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsorcio);
	
	// Cria objeto para classe de tratamento de XML
	$xmlGetDadosConsorcio = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlGetDadosConsorcio->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlGetDadosConsorcio->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
			
	// Seta a tag de convenios para a variavel
	$consorcio = $xmlGetDadosConsorcio->roottag->tags[0]->tags;
	$registrosConsorcio = $xmlGetDadosConsorcio->roottag->tags[0]->tags[0]->tags;
	
	include('tab_consorcio.php');
			
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
	
?>
