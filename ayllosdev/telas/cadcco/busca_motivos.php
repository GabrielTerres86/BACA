<?php
/*!
 * FONTE        : busca_motivos.php
 * CRIAÇÃO      : Jonathan (RKAM)
 * DATA CRIAÇÃO : Marco/2016 
 * OBJETIVO     : Rotina para buscas os motivos para a tela CADCCO
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
	$cddbanco = (isset($_POST["cddbanco"])) ? $_POST["cddbanco"] : 0;
	$cdocorre = (isset($_POST['cdocorre'])) ? $_POST['cdocorre'] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	
	validaDados();
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
	$xml 	   .= "     <nrconven>".$nrconven."</nrconven>";	
	$xml 	   .= "     <cddbanco>".$cddbanco."</cddbanco>";
	$xml 	   .= "     <cdocorre>".$cdocorre."</cdocorre>";		
	$xml 	   .= "     <cddepart>".$glbvars['cddepart']."</cddepart>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "     <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xml	   .= "     <nrregist>".$nrregist."</nrregist>";	
	$xml	   .= "     <nriniseq>".$nriniseq."</nriniseq>";		
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADCCO", "CONSMOTIVOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjMotivos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjMotivos->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjMotivos->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesTarifas\').focus();',false);		
					
	} 
		
	$motivos   = $xmlObjMotivos->roottag->tags[0]->tags;
    $qtregist  = $xmlObjMotivos->roottag->attributes["QTREGIST"];

	include("form_motivos.php");

	function validaDados(){
		
		//Convenio
		if ( $GLOBALS["nrconven"] == 0){ 
			exibirErro('error','Conv&ecirc;nio inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesTarifas\').focus();',false);
		}
	
	}

 ?>
