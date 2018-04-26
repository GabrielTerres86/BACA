<?php 
/***************************************************************************************
 * FONTE        : titulos_renova_limite.php				�ltima altera��o: --/--/----
 * CRIA��O      : Leonardo
 * DATA CRIA��O : 13/03/2018
 * OBJETIVO     : Efetuar renova��o Manual de Limites.
 *
 * Altera��es   : 
 *
 * 001: [16/03/2018] Leonardo Oliveira (GFT): Considerar o par�metro 'cddlinha' na opera��o.
 * 002: [25/04/2018] Leonardo Oliveira (GFT): Corre��o da mensagem de erro.
 *
 **************************************************************************************/

	session_start();
		
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../class/xmlfile.php');
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibirErro('error',htmlentities($msgError),'Alerta - Ayllos',"blockBackground(parseInt($('#divUsoGenerico').css('z-index')))",false);
	}
	
	isPostMethod();		
	  
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0;
	$cddlinha = (isset($_POST['cddlinha'])) ? $_POST['cddlinha'] : 0;

    $xmlRenovaLimite  = "";
	$xmlRenovaLimite .= "<Root>";
	$xmlRenovaLimite .= "   <Dados>";
	$xmlRenovaLimite .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlRenovaLimite .= "	   <idseqttl>1</idseqttl>";
	$xmlRenovaLimite .= "	   <vllimite>".$vllimite."</vllimite>";
	$xmlRenovaLimite .= "	   <nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlRenovaLimite .= "	   <cddlinha>".$cddlinha."</cddlinha>";
	$xmlRenovaLimite .= "   </Dados>";
	$xmlRenovaLimite .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria(
		$xmlRenovaLimite, 
		"TELA_ATENDA_DESCTO", 
		"RENOVA_LIMITE_TIT", 
		$glbvars["cdcooper"], 
		$glbvars["cdagenci"], 
		$glbvars["nrdcaixa"], 
		$glbvars["idorigem"], 
		$glbvars["cdoperad"], 
		"</Root>");
	
	$xmlObjRenovaLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRenovaLimite->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjRenovaLimite->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjRenovaLimite->roottag->tags[0]->cdata;
		}
		exibirErro(
			"error",
			htmlentities($msgErro),
			"Alerta - Ayllos",
			"fecharRotinaGenerico('TITULOS');",
			false);
	}
	
	echo "showError(
			\"inform\",
			\"Opera&ccedil;&atilde;o efetuada com sucesso!\",
			\"Alerta - Ayllos\",
			\"fecharRotinaGenerico('TITULOS');\");";	
?>