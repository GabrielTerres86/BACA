<?php
//*********************************************************************************************//
//*** Fonte: grava_custodia.php                                    						              ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Grava os dados da tela de custodia.                                       ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//

	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	/*
	dataB3: dataB3,
  vlminB3: vlminB3,
	nomarq: nomarq,
	qtdarq: qtdarq,
	dsmail: dsmail,
	hrinicio: hrinicio,
	hrfinal: hrfinal,
	reghab: reghab,
	rgthab: rgthab,
	cnchab: cnchab,
	*/

	$originalDate = (isset($_POST['dataB3']))  ? $_POST['dataB3']  : '' ;
	$vlminB3 = (isset($_POST['vlminB3']))  ? $_POST['vlminB3']  : '' ;
	$nomarq = (isset($_POST['nomarq']))  ? $_POST['nomarq']  : '' ;
	$dsmail = (isset($_POST['dsmail']))  ? $_POST['dsmail']  : '' ;
	$hrinicio = (isset($_POST['hrinicio']))  ? $_POST['hrinicio']  : '' ;
	$hrfinal = (isset($_POST['hrfinal']))  ? $_POST['hrfinal']  : '' ;
	$reghab = (isset($_POST['reghab']))  ? $_POST['reghab']  : '' ;
	$rgthab = (isset($_POST['rgthab']))  ? $_POST['rgthab']  : '' ;
	$cnchab = (isset($_POST['cnchab']))  ? $_POST['cnchab']  : '' ;

	/*$dataB3 = date("d/m/Y", strtotime($originalDate));*/
 
	$xmlCarregaDados = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= " <datab3>".$originalDate."</datab3>";
  $xmlCarregaDados .= " <vlminb3>".$vlminB3."</vlminb3>";
	$xmlCarregaDados .= " <nomarq>".$nomarq."</nomarq>";
	$xmlCarregaDados .= " <dsmail>".$dsmail."</dsmail>";
	$xmlCarregaDados .= " <hrinicio>".$hrinicio."</hrinicio>";
	$xmlCarregaDados .= " <hrfinal>".$hrfinal."</hrfinal>";
	$xmlCarregaDados .= " <reghab>".$reghab."</reghab>";
	$xmlCarregaDados .= " <rgthab>".$rgthab."</rgthab>";
	$xmlCarregaDados .= " <cnchab>".$cnchab."</cnchab>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados
		,"TELA_CUSAPL"
		,"CUSAPL_GRAVAC_PARAMS"
		,$glbvars["cdcooper"]
		,$glbvars["cdagenci"]
		,$glbvars["nrdcaixa"]
		,$glbvars["idorigem"]
		,$glbvars["cdoperad"]
		,"</Root>");

	$xmlObject = getObjectXML($xmlResult);

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
		$msgErro = $xmlObject->roottag->tags[0]->cdata;
		if ($msgErro == '') {
			$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}

	echo "showError('inform','Dados gravados com sucesso!','CUSAPL','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>
