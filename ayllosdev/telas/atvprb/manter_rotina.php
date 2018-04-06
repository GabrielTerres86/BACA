<?
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 23/03/2018
 * OBJETIVO     : Rotina para manter as operações da tela ATVPRB
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
	$operacao		= (isset($_POST['operacao'])) ? $_POST['operacao']  : '';
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao']  : '';
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta']  : '0';
  $nrctrato		= (isset($_POST['nrctrato'])) ? $_POST['nrctrato']  : '0';
  $cdmotivo		= (isset($_POST['flmotivo'])) ? $_POST['flmotivo']  : '0';
  $datainic		= (isset($_POST['datainic'])) ? $_POST['datainic']  : '01/01/1980';
  $datafina		= (isset($_POST['datafina'])) ? $_POST['datafina']  : '01/01/1980';
  $dsobserv		= (isset($_POST['dsobserv'])) ? $_POST['dsobserv']  : '';

  // Montar o xml de Requisicao com os dados da operação
	$xml = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrctremp>".$nrctrato."</nrctremp>";
	$xml .= "		<cdmotivo>".$cdmotivo."</cdmotivo>";
  $xml .= "		<datainic>".$datainic."</datainic>";
  $xml .= "		<datafina>".$datafina."</datafina>";
	$xml .= "		<dsobserv>".$dsobserv."</dsobserv>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

  $msgSucesso = "";
  $nomesAcao  = array("Valida_Dados"=>"ATVPRB_CONSULTA",
                      "Inclui_Dados"=>"ATVPRB_INCLUSAO",
                      "Altera_Dados"=>"ATVPRB_ALTERACAO",
                      "Exclui_Dados"=>"ATVPRB_EXCLUSAO",
                      "Historico_Dados"=>"CONSULTA_HIS_ATIVO_PROB");
  $nomeAcao   = $nomesAcao[$operacao];

  // $xml = "";
	// $xml .= "<Root>";
  // $xml .= " <Dados>";
	// $xml .= "		<nrdconta>213</nrdconta>";
	// $xml .= "		<cdcooper>11</cdcooper>";
	// $xml .= "		<nrctremp>158003</nrctremp>";
	// $xml .= "		<cdmotivo>58</cdmotivo>";
	// $xml .= "		<dsobserv>aaaa</dsobserv>";
  // $xml .= " </Dados>";
  // $xml .= "</Root>";
  //
  // $nomeAcao   ="ATVPRB_INCLUSAO";

  if (!empty($nomeAcao)) {
    $xmlResult = mensageria($xml, "TELA_ATVPRB", $nomeAcao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    $retornoRotina = $xmlObjeto->roottag->tags[0]->tags;

    if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
      $msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
      exibirErro('error', (empty($msgErro) ? "Erro Indefinido" : $msgErro), 'Alerta - Ayllos', '', false);
    } else if ($operacao =='Valida_Dados') {
      include "lista_consulta.php";
    } else if ($operacao =='Historico_Dados') {
      include "lista_historico.php";
    } else if ($operacao =='Exclui_Dados' || $operacao =='Altera_Dados') {
      $msgSucesso = "Registro alterado com sucesso!";
      echo "fechaRotina($('#divUsoGenerico')); continuarFiltro();";
    } else if ($operacao =='Inclui_Dados') {
      $msgSucesso = "Registro inclu&iacute;do com sucesso!";
      echo "fechaRotina($('#divUsoGenerico')); continuarFiltro();";
    } else {
      echo json_encode($retornoRotina);
    }

    if ($msgSucesso !== "") {
      echo 'showError("inform", "' . $msgSucesso . '","Notifica&ccedil;&atilde;o - Ayllos","");';
    }
  }
?>
