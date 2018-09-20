<?
/*!
 * FONTE        : busca_pacote.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Abril/2016
 * OBJETIVO     : Busca a descrição do pacote

**************************************************************************************/

	session_start();
		
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$cdpacote = (isset($_POST['cdpacote'])) ? $_POST['cdpacote'] : 0;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;
	
    $xmlBuscaPacote  = "";
	$xmlBuscaPacote .= "<Root>";
	$xmlBuscaPacote .= "   <Dados>";
	$xmlBuscaPacote .= "	   <cdpacote>".$cdpacote."</cdpacote>";
	$xmlBuscaPacote .= "	   <inpessoa>".$inpessoa."</inpessoa>";
	$xmlBuscaPacote .= "   </Dados>";
	$xmlBuscaPacote .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaPacote, "ADEPAC", "BUSCA_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscaPacote = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBuscaPacote->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = utf8_encode($xmlObjBuscaPacote->roottag->tags[0]->tags[0]->tags[4]->cdata);
				 
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#cdpacote\').focus();bloqueiaFundo(divRotina)',false);		
							
	} 
	
	echo $xmlObjBuscaPacote->roottag->tags[0]->cdata;
	
?>