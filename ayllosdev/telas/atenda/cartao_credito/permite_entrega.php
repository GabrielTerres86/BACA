<?php 
session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	
	
	$cdoperad = $glbvars['cdoperad'];
	$nrcrcard = $_POST['nrcrcard'];
	$nrdconta = $_POST['nrdconta'];
	if (!validaInteiro($nrcrcard) || !validaInteiro($nrdconta)) exibirErro('error',utf8ToHtml('Cartão inválido '.$nrcrcard),'Alerta - Aimaro','bloqueiaFundo(divRotina);');
	
	//nrcrcard
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>$nrdconta</nrdconta>";
	$xml .= "   <nrcrcard>".$nrcrcard."</nrcrcard>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$admresult = mensageria($xml, "ATENDA_CRD", "VALIDA_ENTREGA_OPERADOR", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$admxmlObj = getObjectXML($admresult);
	$xml_adm =  simplexml_load_string($admresult);
	$nm = $xml_adm->Dados->cartoes->cartao->operador;
	$result = "";
	foreach($nm as $key => $value){
		if($value != 'N')
			echo utf8ToHtml('showError("error", "O operador que realizou a solicitação do cartão não poderá efetuar a entrega do cartão.", "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));voltaDiv(0,1,4)")');
		break;
	}
		
?>