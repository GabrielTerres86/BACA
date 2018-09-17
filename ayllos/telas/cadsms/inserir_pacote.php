<?php
	/*************************************************************************
	  Fonte: inserir_pacote.php
	  Autor: Ricardo Linhares
	  Data : Fevereiro/2016                       Última Alteração: --/--/----

	  Objetivo  : Grava os dados.

	  Alterações:

	***********************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");


	$cdcooper 	= (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : $glbvars["cdcooper"];
	$idpacote 	= $_POST["idpacote"];
	$dspacote 	= $_POST["dspacote"];
	$flgstatus 	= $_POST["flgstatus"];
	$cdtarifa 	= $_POST["cdtarifa"];
	$perdesconto = $_POST["perdesconto"];
	$inpessoa 	= $_POST["inpessoa"];
	$qtdsms		= $_POST["qtdsms"];


	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "	<cooper>".$cdcooper."</cooper>";
	$xml .= "	<idpacote>".$idpacote."</idpacote>";
	$xml .= "	<dspacote>".utf8_decode($dspacote)."</dspacote>";
	$xml .= "	<flgstatus>".$flgstatus."</flgstatus>";
	$xml .= "	<cdtarifa>".$cdtarifa."</cdtarifa>";
	$xml .= "	<perdesconto>".converteFloat($perdesconto)."</perdesconto>";
	$xml .= "	<inpessoa>".$inpessoa."</inpessoa>";
	$xml .= "	<qtdsms>".$qtdsms."</qtdsms>";
	$xml .= " 	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADSMS", "INSERIR_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	} else {
		$dsmensag = 'Pacote inserido com sucesso!';
		echo "showError('inform','".$dsmensag."','Pacotes SMSs','fechaRotina($(\'#divRotina\'));FormularioPacote.inicializar();');";
	}

?>
