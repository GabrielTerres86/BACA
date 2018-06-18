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
	cdregtb3: cdregtb3,
	cdfavrcb3: cdfavrcb3,
	*/

	$originalDate = (isset($_POST['dataB3']))  ? $_POST['dataB3']  : '' ;
	$vlminB3 = (isset($_POST['vlminB3']))  ? $_POST['vlminB3']  : '' ;
	$cdregtb3 = (isset($_POST['cdregtb3']))  ? $_POST['cdregtb3']  : '' ;
	$cdfavrcb3 = (isset($_POST['cdfavrcb3']))  ? $_POST['cdfavrcb3']  : '' ;
	$cdcoopera = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';

	/*$dataB3 = date("d/m/Y", strtotime($originalDate));*/

	$xmlCarregaDados = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= " <tlcdcooper>".$cdcoopera."</tlcdcooper>";
	$xmlCarregaDados .= " <datab3>".$originalDate."</datab3>";
  $xmlCarregaDados .= " <vlminb3>".$vlminB3."</vlminb3>";
	$xmlCarregaDados .= " <cdregtb3>".$cdregtb3."</cdregtb3>";
	$xmlCarregaDados .= " <cdfavrcb3>".$cdfavrcb3."</cdfavrcb3>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados
		,"TELA_CUSAPL"
		,"CUSAPL_GRAVAC_PARAMS_COOP"
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
