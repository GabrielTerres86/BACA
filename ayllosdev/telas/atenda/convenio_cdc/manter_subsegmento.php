<?php
	/*!
	 * FONTE        : manter_subsegmento.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : 30/11/2017
	 * OBJETIVO     : Mantem informações de subsegmentos
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao        = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	$idcooperado_cdc = (isset($_POST['idcooperado_cdc'])) ? $_POST['idcooperado_cdc'] : '';
	$cdsubsegmento   = (isset($_POST['cdsubsegmento']))   ? $_POST['cdsubsegmento']   : '';
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
	   exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	   exit();
    }

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<idcooperado_cdc>".$idcooperado_cdc."</idcooperado_cdc>";
	$xml .= "		<cdsubsegmento>".$cdsubsegmento."</cdsubsegmento>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml,"TELA_ATENDA_CVNCDC","MANTEM_SUBSEGMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
    
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
				$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',utf8_encode(str_replace("\"", "",$msgErro)),'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		exit();
	}
	echo "acessaOpcaoAba('S',0);";
?>