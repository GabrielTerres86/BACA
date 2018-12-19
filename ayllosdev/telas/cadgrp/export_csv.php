<?php
/*!
 * FONTE        : exportar_csv.php
 * CRIAÇÃO      : Gabriel Marcos - (Mouts)
 * DATA CRIAÇÃO : 14/12/2018
 * OBJETIVO     : 
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
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	// Ler parametros passados via POST
	$cddopcao  = (isset($_POST['cddopcao']))  ? $_POST['cddopcao']  : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	$cdagenci 	= (isset($_POST["cdagenci"])) 	? $_POST["cdagenci"] : 0;
	$nrdgrupo 	= (isset($_POST["nrdgrupo"])) 	? $_POST["nrdgrupo"] : 0;

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xml .= "		<nrdgrupo>".$nrdgrupo."</nrdgrupo>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", 'UPLOAD_IMPORTACAO_GRUPO', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {

		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','controlaVoltar(\'5\')',false);		
		
    } else {
	
		$nmarquiv = $xmlObjeto->roottag->tags[0]->tags[0]->tags[0]->cdata;
		echo 'Gera_Impressao("'.$nmarquiv.'","controlaVoltar(\'5\');");';	
	
	}
	
 ?>