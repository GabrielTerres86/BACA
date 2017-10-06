<?php

/* !
 * FONTE        : busca_dados_simulacao.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 27/06/2011
 * OBJETIVO     : Executa os processos da rotina filha de Simulações da rotina de Empréstimos 

 * ALTERACOES	: 02/04/2012 - Incluido campo %CET (Gabriel)
 *                30/06/2015 - Ajustes referentes Projeto 215 - DV3 (Daniel)

 * */
session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'C')) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Guardo os parâmetos do POST em variáveis	
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
$nrsimula = (isset($_POST['nrsimula'])) ? $_POST['nrsimula'] : '';
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$dtlibera = (isset($_POST['dtlibera'])) ? $_POST['dtlibera'] : '';
// Monta o xml de requisição
$xml = "";
$xml.= "<Root>";
$xml.= "	<Cabecalho>";
$xml.= "		<Bo>b1wgen0097.p</Bo>";
$xml.= "		<Proc>busca_dados_simulacao</Proc>";
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
$xml.= "		<nrsimula>" . $nrsimula . "</nrsimula>";
$xml.= "	</Dados>";
$xml.= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);
// Cria objeto para classe de tratamento de XML
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
    echo 'showError("error","' . $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata . '","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
} else {
    $dados_simulacao = $xmlObj->roottag->tags[0]->tags;
    if ($operacao == "GPR" || $operacao == "TI") {
        $retorno = '$("#vlemprst","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'vlemprst') . '");
					$("#vlemprst","#frmNovaProp").blur();
					$("#vlpreemp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'vlparepr') . '");
					$("#qtdialib","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'nrdialib') . '");
					$("#dtlibera","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dtlibera') . '");
					$("#qtpreemp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'qtparepr') . '");
					$("#cdlcremp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'cdlcremp') . '");
					$("#dslcremp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dslcremp') . '");
					$("#dtdpagto","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dtdpagto') . '");
					$("#cdfinemp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'cdfinemp') . '");
					$("#dsfinemp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dsfinemp') . '");
					$("#percetop","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'percetop') . '");
				    $("#flgpagto","#frmNovaProp").val("no");';
    } else {
        $idfiniof = getByTagName($dados_simulacao[0]->tags, 'idfiniof');
        if ($idfiniof == ""){
            $idfiniof = "1";
        }
        $retorno = '$("#vlemprst","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'vlemprst') . '");
					$("#qtparepr","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'qtparepr') . '");
					$("#cdlcremp","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'cdlcremp') . '");
					$("#dtlibera","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dtlibera') . '");
					$("#dtdpagto","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dtdpagto') . '");
					$("#dslcremp","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dslcremp') . '");
					$("#percetop","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'percetop') . '");
					$("#cdfinemp","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'cdfinemp') . '");
                    $("#dsfinemp","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dsfinemp') . '");
                    $("#vliofepr","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'vliofepr') . '");
                    $("#vlrtarif","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'vlrtarif') . '");
                    $("#vlrtotal","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'vlrtotal') . '");                    
                    $("#idfiniof","#frmSimulacao").val("' . $idfiniof . '");
                    $("#frmSimulacao #cdmodali option").each(function() {
                        if ("' . getByTagName($dados_simulacao[0]->tags, 'cdmodali') . '" == $(this).val()) {
                            $(this).attr("selected", "selected");
                        }
                    });';


        if ($operacao == "C_SIMULACAO" || $operacao == "E_SIMULACAO") {
            $parcelas = $xmlObj->roottag->tags[1]->tags;
            $retorno .= "arraySimulacoes.length = 0;";
            foreach ($parcelas as $indice => $parcela) {

                $retorno .= 'var arraySimulacao' . $indice . ' = new Object();
								 arraySimulacao' . $indice . '[\'nrparepr\'] = "' . getByTagName($parcela->tags, 'nrparepr') . '";
								 arraySimulacao' . $indice . '[\'vlparepr\'] = "' . getByTagName($parcela->tags, 'vlparepr') . '"; 
								 arraySimulacao' . $indice . '[\'dtparepr\'] = "' . getByTagName($parcela->tags, 'dtparepr') . '"; 
								 arraySimulacoes[' . $indice . '] = arraySimulacao' . $indice . ';';
            }
        }
        $retorno .= 'controlaLayoutSimulacoes("' . $operacao . '", "' . $nrsimula . '");hideMsgAguardo();';
    }
    echo $retorno;
}
?>