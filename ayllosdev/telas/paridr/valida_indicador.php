<?php
	/*************************************************************************
	  Fonte: valida_indicador.php
	  Autor: Lucas Reinert                                          
	  Data : Março/2016                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Valida o indicador inserido
	                                                                 
	  Alterações: 
				  
	***********************************************************************/
	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	$idindica = (isset($_POST['idindica'])) ? $_POST['idindica'] : 0  ;	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "	<idindica>".$idindica."</idindica>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "TELA_PARIDR", "VALIDA_INDICADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos','limpaIndicador();',false);
	}else{
		$nmindica = $xmlObj->roottag->tags[0]->tags[0]->tags[0]->cdata;
		$tpindica = $xmlObj->roottag->tags[0]->tags[0]->tags[1]->cdata;
		echo 'cNmindica.val("'.$nmindica.'"); cTpindica.val("'.$tpindica.'");';
	}
?>