<?
/*
 * FONTE        : paga_liberacao_cc.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 04/07/2018
 * OBJETIVO     : Realizar liberação de saque Conta Transitória.
   ALTERACOES   :
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');


	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
    $vlrpagto = (isset($_POST['vlrpagto'])) ? str_replace(",",".",$_POST['vlrpagto']) : 0;
  
    // pagamento de prejuízo via liberação de saque		

	$xml2  = "<Root>";
	$xml2 .= " <Dados>";
	$xml2 .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml2 .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml2 .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml2 .= "   <vlrlanc>".$vlrpagto ."</vlrlanc>";
	$xml2 .= " </Dados>";
	$xml2 .= "</Root>";

	$acao = "GERA_LCM";	

	$xmlResult = mensageria($xml2, "PREJ0003", $acao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',utf8ToHtml($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos',"",false);
	}else{
		exibirErro('inform',utf8ToHtml('Liberação efetuada com sucesso!'),'Alerta - Ayllos',"",false);
	}

?>