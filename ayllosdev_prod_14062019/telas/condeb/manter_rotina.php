<?
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 16/04/2018
 * OBJETIVO     : Rotina para manter as operações da tela CONDEB
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
	$situacao	= (!empty($_POST['situacao'])) ? $_POST['situacao']  : '';
  $cdoperac = ($situacao == 'pendentes' ? '1' : '2');
	$nrdconta	= (!empty($_POST['nrdconta'])) ? $_POST['nrdconta']  : '';
  $dtmvtolt	= (!empty($_POST['dtmvtolt'])) ? $_POST['dtmvtolt']  : '01/01/1980';
  $nrpagina	= (!empty($_POST['nrpagina'])) ? $_POST['nrpagina']  : '1';
  $cdagenci = (!empty($_POST['cdagenci'])) ? $_POST['cdagenci']  : '';
  $flprogra = (!empty($_POST['flprogra'])) ? $_POST['flprogra']  : '';

  $msgErro = "";

  $datmvmto = DateTime::createFromFormat('d/m/Y', $dtmvtolt);
  $dtagenci = DateTime::createFromFormat('d/m/Y', $glbvars['dtmvtolt']);
  $datamn30 = $dtagenci;
  $datamn30->sub(new DateInterval("P30D"));

  if ($cdoperac == "1" && $datmvmto < $dtagenci) {
    $msgErro = "Data deve ser maior ou igual a hoje";
  } else if ($cdoperac == "2" && $datmvmto < $datamn30) {
    $msgErro = "Data n&atilde;o pode ser menor que trinta dias";
  } else if (strlen(trim($cdagenci)) == 0) {
    $msgErro = "Informar c&oacute;digo do PA";
  }

  //valida pa informado
  if ($msgErro == "") {
    $xml = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "		<cdagenci>".$cdagenci."</cdagenci>";
    $xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_DEB_PEN_EFETIVADOS", 'CONDEB_VALIDA_PA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    $retornoRotina = $xmlObjeto->roottag->tags[0]->tags;
    $agenciaRetorno = preg_replace("/\/\/.*?\n/", "\n", $retornoRotina[0]->cdata);

    if ($agenciaRetorno !== $cdagenci) {
      $msgErro = "N&uacute;mero do PA Inv&aacute;lido";
    }
  }

  // Montar o xml de Requisicao com os dados da operação
  if ($msgErro == "") {
  	$xml = "";
  	$xml .= "<Root>";
  	$xml .= " <Dados>";
    $xml .= "		<tipoexec>".$cdoperac."</tipoexec>";
  	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
  	$xml .= "		<cdagenci>".$cdagenci."</cdagenci>";
    $xml .= "		<dtmvtolt>".$dtmvtolt."</dtmvtolt>";
    $xml .= "		<pagina>".$nrpagina."</pagina>";

    if ($cdoperac == '1') {
      $xml .= "		<ds_cdprocesso>".$flprogra."</ds_cdprocesso>";
    }

    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
  	$xml .= " </Dados>";
  	$xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_DEB_PEN_EFETIVADOS", 'CONDEB_BUSCA_DEBITOS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    $retornoRotina = $xmlObjeto->roottag->tags[0]->tags;

    // prepara dados da paginação
    $nrRegRetorno = count($retornoRotina);
    $regInicial = $nrRegRetorno > 0 ? $xmlObjeto->roottag->tags[1]->cdata : 0;
    $totRegistros = $xmlObjeto->roottag->tags[3]->cdata;
    $regPorPagina = $xmlObjeto->roottag->tags[2]->cdata;
    $regFinal = $regInicial > 0 ? (($regInicial-1) + $nrRegRetorno) : 0;
    $ehPrimeiraPagina = (($regInicial - $regPorPagina) <= 0);
    $ehUltimaPagina = (($regInicial + $regPorPagina) >= $totRegistros);

    if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
      $msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
      exibirErro('error', (empty($msgErro) ? "Erro Indefinido" : $msgErro), 'Alerta - Ayllos', '', false);
    } else if ($situacao =='pendentes') {
      include "lista_pendentes.php";
    } else if ($situacao =='efetivados') {
      include "lista_efetivados.php";
    } else {
      echo json_encode($retornoRotina);
    }
  }

  if ($msgErro !== "") {
    echo 'showError("error", "' . $msgErro . '","Notifica&ccedil;&atilde;o - Ayllos","");';
  }
?>
