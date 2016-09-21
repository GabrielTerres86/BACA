<?php 
	/*********************************************************************
	 Fonte: buscar_rotina.php                                                 
	 Autor: Renato Darosci                                                   
	 Data : Ago/2016                Última Alteração: 29/08/2016 
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela PROVIS
	                                                                  
	 Alterações: 
	 
	**********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"","@")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_PROVIS", "PROVISCL_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	
	// Retornar os valores
	echo 'cVlriscoA.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_A').'");';
	echo 'cVlriscoB.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_B').'");';
	echo 'cVlriscoC.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_C').'");';
	echo 'cVlriscoD.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_D').'");';
	echo 'cVlriscoE.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_E').'");';
	echo 'cVlriscoF.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_F').'");';
	echo 'cVlriscoG.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_G').'");';
	echo 'cVlriscoH.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_H').'");';
	echo 'cVlriscAA.val("'.getByTagName($xmlObjeto->roottag->tags,'risco_AA').'");';
	echo 'cVlriscAA.focus();';
?>
