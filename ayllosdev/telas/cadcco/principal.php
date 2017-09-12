<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jonathan - RKAM
 * DATA CRIAÇÃO : Marco/2016
 * OBJETIVO     : Rotina para manter as operações da tela CADCCO
 * --------------
 * ALTERAÇÕES   : 30/11/2016 - P341-Automatização BACENJUD - Alterado para passar como parametro o  
 *                             código do departamento ao invés da descrição (Renato Darosci - Supero)
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

	$nrconven = (isset($_POST["nrconven"])) ? $_POST["nrconven"] : 0;
	
	validaDados();
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrconven>".$nrconven."</nrconven>";
	$xml 	   .= "     <cddepart>".$glbvars['cddepart']."</cddepart>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "     <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADCCO", "CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicita = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicita->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjSolicita->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#nrconven\',\'#frmFiltro\').habilitaCampo().focus();',false);		
					
	} 
		
	$inf   = $xmlObjSolicita->roottag->tags[0]->tags[0]->tags;
	$tar   = $xmlObjSolicita->roottag->tags[0]->tags[1]->tags;
    $exisbole = $xmlObjSolicita->roottag->tags[0]->attributes["EXISTBOLE"];	

	include("form_cadcco.php");

	function validaDados(){
		
		//Convenio
		if ( $GLOBALS["nrconven"] == 0){ 
			exibirErro('error','Conv&ecirc;nio inv&aacute;lido.','Alerta - Ayllos','$(\'#nrconven\',\'#frmFiltro\').habilitaCampo().focus();',false);
		}
	
	}

 ?>