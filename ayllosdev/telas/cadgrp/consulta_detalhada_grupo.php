<?php
/*!
 * FONTE        : consulta_detalhada_grupo.php
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

	$cdagenci 	= (isset($_POST["cdagenci"])) 	? $_POST["cdagenci"] : 0;
	$nrdgrupo 	= (isset($_POST["nrdgrupo"])) 	? $_POST["nrdgrupo"] : 0;
	$nriniseq 	= (isset($_POST["nriniseq"])) 	? $_POST["nriniseq"] : 0;
	$nrregist 	= (isset($_POST["nrregist"])) 	? $_POST["nrregist"] : 0;
	$qtdRetorno = (isset($_POST["qtdRetorno"])) ? $_POST["qtdRetorno"] : 0;

	if($qtdRetorno !== 0)
		$nrregist = $qtdRetorno;
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <cdagenci>".$cdagenci."</cdagenci>";
	$xml 	   .= "     <nrdgrupo>".$nrdgrupo."</nrdgrupo>";
	$xml 	   .= "     <nrregist>".$nrregist."</nrregist>";
	$xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>"; //Numero inicial sequencia
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADGRP", "CONSULTA_DET_GRP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjRegistros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRegistros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjRegistros->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdagenci";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','formataFiltroConsultaDetalhada();focaCampoErro(\''.$nmdcampo.'\',\'frmFiltroConsultaDetalhada\');',false);		
								
	} 
		
	$registros	= $xmlObjRegistros->roottag->tags[0]->tags[0]->tags;	
	$qtregist = $xmlObjRegistros->roottag->tags[0]->attributes['QTREGIST'];
	
	include("tabela_detalhada_grupo.php");


 ?>
