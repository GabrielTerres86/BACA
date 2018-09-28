<?php
//*********************************************************************************************//
//*** Fonte: grava_parametros_gravam.php                                    						              ***//
//*** Autor: Thaise Medeiros - Envolti                                           						***//
//*** Data : Setembro/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Grava os dados da tela de parâmetros de gravame.                                       ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//**********************************************************************************************//

	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	

	$nrdiaenv = (isset($_POST['nrdiaenv']))  ? $_POST['nrdiaenv']  : '' ;
	$hrenvi01 = (isset($_POST['hrenvi01']))  ? $_POST['hrenvi01']  : '' ;
	$hrenvi02 = (isset($_POST['hrenvi02']))  ? $_POST['hrenvi02']  : '' ;
	$hrenvi03 = (isset($_POST['hrenvi03']))  ? $_POST['hrenvi03']  : '' ;
	$aprvcord = (isset($_POST['aprvcord']))  ? $_POST['aprvcord']  : '' ;
	$perccber = (isset($_POST['perccber']))  ? $_POST['perccber']  : '' ;
	$tipcomun = (isset($_POST['tipcomun']))  ? $_POST['tipcomun']  : '' ;
	$nrdnaoef = (isset($_POST['nrdnaoef']))  ? $_POST['nrdnaoef']  : '' ;
	$emlnaoef = (isset($_POST['emlnaoef']))  ? $_POST['emlnaoef']  : '' ;

	/*$dataB3 = date("d/m/Y", strtotime($originalDate));*/
 
	$xmlCarregaDados = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= " <nrdiaenv>".$nrdiaenv."</nrdiaenv>";
	$xmlCarregaDados .= " <hrenvi01>".$hrenvi01."</hrenvi01>";
	$xmlCarregaDados .= " <hrenvi02>".$hrenvi02."</hrenvi02>";
	$xmlCarregaDados .= " <hrenvi03>".$hrenvi03."</hrenvi03>";
	$xmlCarregaDados .= " <aprvcord>".$aprvcord."</aprvcord>";
	$xmlCarregaDados .= " <perccber>".$perccber."</perccber>";
	$xmlCarregaDados .= " <tipcomun>".$tipcomun."</tipcomun>";
	$xmlCarregaDados .= " <nrdnaoef>".$nrdnaoef."</nrdnaoef>";
	$xmlCarregaDados .= " <emlnaoef>".$emlnaoef."</emlnaoef>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados
		,"TELA_GRAVAM"
		,"GRAVAM_GRAVA_PRM"
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
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	}

	echo "showError('inform','Dados gravados com sucesso!','GRAVAM','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>
