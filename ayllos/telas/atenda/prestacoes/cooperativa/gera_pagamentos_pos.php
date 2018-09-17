<?php

	/*************************************************************************
	  Fonte: gera_pagamentos_pos.php
	  Autor: Jaison Fernando
	  Data : Julho/2017                       Ultima Alteracao:

	  Objetivo  : Gera o pagamento das parcelas.

	  Alteracoes:

	***********************************************************************/

	session_start();

	// Includes para controle da session, variaveis globais de controle, e biblioteca de funcoes
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");

	// Dados necessarios
	$nrdconta = $_POST["nrdconta"];
	$nrctremp = $_POST["nrctremp"];
	$idseqttl = $_POST["idseqttl"];
	$camposPc = $_POST["campospc"];
	$dadosPrc = $_POST["dadosprc"];
	$totatual = $_POST["totatual"];
	$totpagto = $_POST['totpagto'];
	$nrseqavl = $_POST['nrseqavl'];

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= "	<Dados>";
	$xml .= "		<dtcalcul>".$glbvars["dtmvtolt"]."</dtcalcul>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
    $xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cdpactra>".$glbvars["cdpactra"]."</cdpactra>";
    $xml .= "		<inproces>".$glbvars['inproces']."</inproces>";
	$xml .= "		<nrseqava>".$nrseqavl."</nrseqava>";
	$xml .= "		<dadosprc>".$dadosPrc."</dadosprc>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "EMPR0011", "EMPR0011_GERA_PAGTO_POS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
        $msgErro  = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaFundo(divRotina);removeOpacidade(\'divConteudoOpcao\');fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'));',false);
	}

	echo "fechaRotina($('#divUsoGenerico'),$('#divRotina')); verificarImpAntecip();";
?>