<?php
/*!
 * FONTE        : busca_grupo_cooperado.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para buscas detalhes do grupo
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
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml 	   .= "     <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "BUSCA_GRUPO_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjRegistros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','formataFiltroBuscaGrupo();focaCampoErro(\''.$nmdcampo.'\',\'frmFiltroBuscaGrupo\');',false);		
								
	} 
		
	$registros	= $xmlObjRegistros->roottag->tags[0]->tags[0];	
	
	include("form_busca_grupo.php");


 ?>
