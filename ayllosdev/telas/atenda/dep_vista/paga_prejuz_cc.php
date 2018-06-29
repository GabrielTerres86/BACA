<?
/*!
 * FONTE        : pagamento_prejuizo.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 29/06/2018
 * OBJETIVO     : Realizar pagamento de prejuizo de conta corrente.

   ALTERACOES   :

 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');


	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
  $vlrpagto = (isset($_POST['vlrpagto'])) ? $_POST['vlrpagto'] : 0;
  $vlrabono = (isset($_POST['vlrabono'])) ? $_POST['vlrabono'] : 0;

	$xml2  = "<Root>";
	$xml2 .= " <Dados>";
	$xml2 .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml2 .= "   <nrdconta>".$nrdconta."</nrdconta>";
  $xml2 .= "   <vlrpagto>".$vlrpagto."</vlrpagto>";
  $xml2 .= "   <vlrabono>".$vlrabono."</vlrabono>";
	$xml2 .= " </Dados>";
	$xml2 .= "</Root>";

	$procedure2 = "PAGA_PREJUZ_CC";

	$xmlResult = mensageria($xml2, "TELA_ATENDA_DEPOSVIS", $procedure2, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$dadosPrejuCC = $xmlObjeto->roottag->tags[0]->tags;

  if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos',"",false);
  }
?>
