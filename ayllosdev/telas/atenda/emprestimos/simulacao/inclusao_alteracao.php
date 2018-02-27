<?php

/* !
 * FONTE        : inclusao_alteracao.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 27/06/2011
 * OBJETIVO     : Executa os processos da rotina filha de Simulações da rotina de Empréstimos 

  ALTERACOES   :  04/08/2014 -  Ajustes referentes ao projeto CET (Lucas R./Gielow)
 *                30/06/2015 - Ajustes referentes Projeto 215 - DV 3 (Daniel)
 *                20/09/2017 - Projeto 410 - Incluir campo Indicador de financiamento do IOF (Diogo - Mouts)
 * */

session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis	
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
$nrsimula = (isset($_POST['nrsimula'])) ? $_POST['nrsimula'] : '';
$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '';
$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : '';
$qtparepr = (isset($_POST['qtparepr'])) ? $_POST['qtparepr'] : '';
$dtlibera = (isset($_POST['dtlibera'])) ? $_POST['dtlibera'] : '';
$dtdpagto = (isset($_POST['dtdpagto'])) ? $_POST['dtdpagto'] : '';
$percetop = (isset($_POST['percetop'])) ? $_POST['percetop'] : '';
$cdfinemp = (isset($_POST['cdfinemp'])) ? $_POST['cdfinemp'] : '';
$idfiniof = (isset($_POST['idfiniof'])) ? $_POST['idfiniof'] : '1';
$cddopcao = (($operacao == "A_SIMULACAO") ? "A" : "I");

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml de requisição
$xml = "";
$xml.= "<Root>";
$xml.= "	<Cabecalho>";
$xml.= "		<Bo>b1wgen0097.p</Bo>";
$xml.= "		<Proc>grava_simulacao</Proc>";
$xml.= "	</Cabecalho>";
$xml.= "	<Dados>";
$xml.= "		<cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xml.= "		<cdagenci>" . $glbvars["cdagenci"] . "</cdagenci>";
$xml.= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
$xml.= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
$xml.= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
$xml.= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
$xml.= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xml.= "		<idseqttl>" . $idseqttl . "</idseqttl>";
$xml .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xml .= "		<flgerlog>TRUE</flgerlog>";
$xml .= "		<cddopcao>" . $cddopcao . "</cddopcao>";
$xml.= "		<nrsimula>" . $nrsimula . "</nrsimula>";
$xml.= "		<cdlcremp>" . $cdlcremp . "</cdlcremp>";
$xml.= "		<vlemprst>" . $vlemprst . "</vlemprst>";
$xml.= "		<qtparepr>" . $qtparepr . "</qtparepr>";
$xml.= "		<dtlibera>" . $dtlibera . "</dtlibera>";
$xml.= "		<dtdpagto>" . $dtdpagto . "</dtdpagto>";
$xml.= "        <percetop>" . $percetop . "</percetop>";
$xml.= "        <cdfinemp>" . $cdfinemp . "</cdfinemp>";
$xml.= "        <idfiniof>" . $idfiniof . "</idfiniof>";
$xml.= "	</Dados>";
$xml.= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObj = getObjectXML($xmlResult);

// Obtém número da simulação gravada
$nrgravad = $xmlObj->roottag->tags[0]->attributes["NRGRAVAD"];
$txcetano = $xmlObj->roottag->tags[0]->attributes['TXCETANO'];

echo "$('#percetop','#frmSimulacao').val('" . $txcetano . "');";

if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata . '","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
} else {

    if ($operacao == "I_SIMULACAO") {
        echo 'ajustaTela();';
        echo "controlaOperacaoSimulacoes('C_INCLUSAO'," . $nrgravad . ");";
    } else {
        echo "mostraTabelaSimulacao('TS');";
    }
}
?>