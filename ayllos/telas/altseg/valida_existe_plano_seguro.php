<?php
	//*************************************************************************************************//
	//*** Fonte      : valida_existe_plano_seguro.php                                               ***//
	//*** Autor      : Cristian Filipe                                                              ***//
	//*** Data       : setembro/2013                                                                ***//
	//*** Objetivo   : Efetuar pesquisa de seguradoras					                            ***//
	//***                                                                                           ***//    
	//*** Alterações : 09/03/2016 - Ajuste feito para que operadores do departamento COORD.PRODUTOS ***//
    //***							tenham permições para alterar e incluir conforme solicitado no  ***//
	//***                           chamado 399940 (Kelvin).						                ***//
	//***                                                                                           ***//
	//***              29/11/2016 - P341-Automatização BACENJUD - Alterado para que seja validado   ***//
    //***                           o acesso pelo cddepart, ao invés do dsdepart. (Renato Darosci)  ***//
	//***                                                                                           ***//
	//*************************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}
	
    if ($cddopcao != "C" &&
		$glbvars["cddepart"] != 20 &&
		$glbvars["cddepart"] != 14 &&
		$glbvars["cddepart"] != 9){ 
		
		$msgError = "Sistema liberado somente para Consulta !!!";
		
		if ($glbvars["redirect"] == "html") {
				redirecionaErro($glbvars["redirect"],$UrlSite."altseg.php","_self",$msgError);
			} elseif ($glbvars["redirect"] == "script_ajax") {
				echo 'hideMsgAguardo();';
				echo 'showError("error","'.addslashes($msgError).'","Alerta - Permiss&otilde;es","");';
			} elseif ($glbvars["redirect"] == "html_ajax") {
				echo '<script type="text/javascript">hideMsgAguardo();showError("error","'.addslashes($msgError).'","Alerta - Permiss&otilde;es","");</script>';
			}
		
		exit();

	} 
	
	
	$cdsegura = (isset($_POST['cdsegura']))? $_POST['cdsegura'] : '';
	$tpseguro = (isset($_POST['tpseguro']))? $_POST['tpseguro'] : '';
	$tpplaseg = (isset($_POST['tpplaseg']))? $_POST['tpplaseg'] : '';
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0033.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>valida_existe_plano_seg</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPesquisa .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPesquisa .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetPesquisa .= "        <nrdconta>".$glbvars["nrdconta"]."</nrdconta>";
	$xmlSetPesquisa .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPesquisa .= "        <idseqttl>".$glbvars["idseqttl"]."</idseqttl>";
	$xmlSetPesquisa .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetPesquisa .= "        <flgerlog>".$glbvars["flgerlog"]."</flgerlog>";
	$xmlSetPesquisa .= "        <cdsegura>".$cdsegura."</cdsegura>";
	$xmlSetPesquisa .= "        <tpseguro>".$tpseguro."</tpseguro>";
	$xmlSetPesquisa .= "        <tpplaseg>".$tpplaseg."</tpplaseg>";
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa);
	

	$xmlObjPesquisa = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
		$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$erros = exibirErro('error',$msgErro,'Alerta - Ayllos',"focaCampoErro('tpplaseg', 'frmInfSeguradora')",false);
	} 	
?>