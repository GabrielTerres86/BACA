<?
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 16/04/2018
 * OBJETIVO     : Rotina para validar contas e pa
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	isPostMethod();
  require_once('../../class/xmlfile.php');

	// Recebe dados
	$nrdconta	= (!empty($_POST['nrdconta'])) ? $_POST['nrdconta']  : '';

  // Montar o xml de Requisicao com os dados da operação
  	$xml = "";
  	$xml .= "<Root>";
  	$xml .= " <Dados>";
  	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
  	$xml .= " </Dados>";
  	$xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_DEB_PEN_EFETIVADOS", 'CONDEB_BUSCA_PA_CONTA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    $retornoRotina = $xmlObjeto->roottag->tags[0]->tags;

    if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
      $msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
      exibirErro('error', (empty($msgErro) ? "Erro Indefinido" : $msgErro), 'Alerta - Ayllos', '', false);
    } else {
      echo json_encode($retornoRotina[0]->cdata);
    }
?>
