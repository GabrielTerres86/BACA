<?php
/*!
 * FONTE        : valida_distribui_conta_grupo.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para valiar distribuicao conta grupos
 * --------------
 * ALTERAÇÕES   : 
 */
?> 

<?php	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		

	$listaCdagenci = (isset($_POST["listaCdagenci"])) ? $_POST["listaCdagenci"] : '';
	$listaQtdgrupo = (isset($_POST["listaQtdgrupo"])) ? $_POST["listaQtdgrupo"] : '';
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <cdagenci>".$listaCdagenci."</cdagenci>";		
	$xml 	   .= "     <qtdgrupo>".$listaQtdgrupo."</qtdgrupo>";		
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "VALIDA_DISTRIBUICAO_GRP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);		
					
	}
	
	echo 'distribuiContaGrupo(\''.$listaCdagenci.'\',\''.$listaQtdgrupo.'\')';

 ?>
