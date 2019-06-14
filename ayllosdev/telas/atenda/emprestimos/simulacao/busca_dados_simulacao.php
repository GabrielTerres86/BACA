<?php

/* !
 * FONTE        : busca_dados_simulacao.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 27/06/2011
 * OBJETIVO     : Executa os processos da rotina filha de Simulações da rotina de Empréstimos 

 * ALTERACOES	: 02/04/2012 - Incluido campo %CET (Gabriel)
 *                30/06/2015 - Ajustes referentes Projeto 215 - DV3 (Daniel)
 *                13/12/2018 - P298.2 - Inclusão da proposta Pos fixado no simulador (Andre Clemer - Supero)
 *				  26/02/2019 - P438	 - Alterada mensageria para ORACLE (Douglas Pagel / AMcom)
 *				  03/2019 - P437	 - Inclusao de consignado

 * */
session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
require_once('../wssoa.php');
isPostMethod();

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'C')) <> '') {
    exibirErro('error', $msgError, 'Alerta - Aimaro', '', false);
}

$vlpreemp = 0;
$vliofepr = 0;
$percetop = 0;
$jurosAnual = '';

// Guardo os parâmetos do POST em variáveis	
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
$nrsimula = (isset($_POST['nrsimula'])) ? $_POST['nrsimula'] : '';
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$dtlibera = (isset($_POST['dtlibera'])) ? $_POST['dtlibera'] : ''; 
// Monta o xml de requisição
$xml = "";
$xml.= "<Root>";
$xml.= "	<Dados>";
$xml.= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xml.= "		<idseqttl>" . $idseqttl . "</idseqttl>";
$xml .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xml .= "		<flgerlog>1</flgerlog>";
$xml.= "		<nrsimula>" . $nrsimula . "</nrsimula>";
$xml.= "	</Dados>";
$xml.= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_ATENDA_SIMULACAO", "SIMULA_BUSCA_DADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
// Cria objeto para classe de tratamento de XML
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
    echo 'showError("error","' . $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata . '","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
} else {
    $dados_simulacao = $xmlObj->roottag->tags;
	$vlpreemp = getByTagName($dados_simulacao[0]->tags, 'vlparepr');
    $vliofepr = getByTagName($dados_simulacao[0]->tags, 'vliofepr'); 
	$percetop = getByTagName($dados_simulacao[0]->tags, 'percetop');
	$dtdpagto = getByTagName($dados_simulacao[0]->tags, 'dtdpagto');
	$cdlcremp = getByTagName($dados_simulacao[0]->tags, 'cdlcremp');
	$vlemprst = getByTagName($dados_simulacao[0]->tags, 'vlemprst');
	$idfiniof = getByTagName($dados_simulacao[0]->tags, 'idfiniof');
	$qtparepr = getByTagName($dados_simulacao[0]->tags, 'qtparepr');
    if ($operacao == "GPR" || $operacao == "TI") {
		$retorno = "";				
		if (getByTagName($dados_simulacao[0]->tags, 'cdmodali') == 2 && getByTagName($dados_simulacao[0]->tags, 'cdsubmod') == 2 && getByTagName($dados_simulacao[0]->tags, 'tpmodcon') > 0 ){				
			//Busca XML BD converte em json e comunica com a FIS	
			$xml  = '';
			$xml .= '<Root>';
			$xml .= '	<dto>';
			$xml .= '       <cdlcremp>'.$cdlcremp.'</cdlcremp>';
			$xml .= '       <vlemprst>'.$vlemprst.'</vlemprst>';
			$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
			$xml .= '       <fintaxas>'.$idfiniof.'</fintaxas>';
			$xml .= '       <quantidadeparcelas>'.$qtparepr.'</quantidadeparcelas>';
			$xml .= '       <dataprimeiraparcela>'.$dtdpagto.'</dataprimeiraparcela>';
			$xml .= '	</dto>';
			$xml .= '</Root>';
			
			$xmlResult = mensageria(
				$xml,
				"TELA_ATENDA_SIMULACAO",
				"SIM_BUSCA_DADOS_CALC_FIS",
				$glbvars["cdcooper"],
				$glbvars["cdagenci"],
				$glbvars["nrdcaixa"],
				$glbvars["idorigem"],
				$glbvars["cdoperad"],
				"</Root>");

			$xmlObj = getObjectXML($xmlResult);

			if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
				gravaLog("TELA_ATENDA_SIMULACAO","SIM_LOG_ERRO_SOA_FIS_CALCULA","Erro gerando o xml com dados.",$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,$nrdconta,$glbvars,'','');
			}else{	
				$xml = simplexml_load_string($xmlResult);
				$json = json_encode($xml);
				//echo "cttc('".$json."');";
				$rs = chamaServico($json,$Url_SOA, $Auth_SOA);
				//echo "cttc('".$rs."');";
				
				if (isset($rs->msg)){
					gravaLog("TELA_ATENDA_SIMULACAO","SIM_LOG_ERRO_SOA_FIS_CALCULA","Retorno erro tratado pela fis.",$rs->msg,$nrdconta,$glbvars,$json,$rs);				
				}else if (isset($rs->errorMessage)){
					gravaLog("TELA_ATENDA_SIMULACAO","SIM_LOG_ERRO_SOA_FIS_CALCULA","Retorno erro nao tratado pela fis.",$rs->errorMessage,$nrdconta,$glbvars,$json,$rs);					
				}			
				else if (isset($rs->parcela->valor) && isset($rs->sistemaTransacao->dataHoraRetorno)){
					if ($rs->parcela->valor > 0 && $rs->sistemaTransacao->dataHoraRetorno != ""){
						$vlpreemp = str_replace(".", ",",$rs->parcela->valor);
						//echo "cttc('".$vlpreemp."');";
						$vliofepr = str_replace(".", ",",$rs->credito->tributoIOFValor);
						$percetop = str_replace(".", ",",$rs->credito->CETPercentAoAno);	
						$jurosAnual = str_replace(".", ",",$rs->credito->taxaJurosRemuneratoriosAnual);
					}else{
						gravaLog("TELA_ATENDA_SIMULACAO","SIM_LOG_ERRO_SOA_FIS_CALCULA","Retorno erro nao tratado pela fis.","valores de retorno em branco",$nrdconta,$glbvars,$json,$rs);
					}
				}
				
			}
			
			
		}	
		
        $retorno .= '$("#tpemprst","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'tpemprst') . '");
        			$("#vlemprst","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'vlemprst') . '");
					$("#vlemprst","#frmNovaProp").blur();
					$("#vlpreemp","#frmNovaProp").val("' . $vlpreemp  . '");
                    $("#vlpreemp","#frmNovaProp").blur();
					$("#qtdialib","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'nrdialib') . '");
					$("#dtlibera","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dtlibera') . '");
					$("#qtpreemp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'qtparepr') . '");
					$("#cdlcremp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'cdlcremp') . '");
					$("#dslcremp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dslcremp') . '");
					$("#dtdpagto","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dtdpagto') . '");
					$("#cdfinemp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'cdfinemp') . '");
					$("#dsfinemp","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dsfinemp') . '");
					$("#percetop","#frmNovaProp").val("' . $percetop . '");
					$("#idfiniof","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'idfiniof') . '");
                    $("#idcarenc","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'idcarenc') . '");
                    $("#dtcarenc","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'dtcarenc') . '");
                    $("#vlprecar","#frmNovaProp").val("' . getByTagName($dados_simulacao[0]->tags, 'vlprecar') . '");
					$("#vliofepr","#frmNovaProp").val("' . $vliofepr  . '");
                    if ($("#tpemprst","#frmNovaProp").val() == 2) {
                        exibeLinhaCarencia("#frmNovaProp");
                        $("#vlprecar","#frmNovaProp").blur();
                    }                    

				  $("#flgpagto","#frmNovaProp").val("no");';
    } else {
        $idfiniof = getByTagName($dados_simulacao[0]->tags, 'idfiniof');
        if ($idfiniof == ""){
            $idfiniof = "1";
        }
		
		$vlpreemp = getByTagName($dados_simulacao[0]->tags, 'vlpreemp');
        $vliofepr = getByTagName($dados_simulacao[0]->tags, 'vliofepr');        		
		
		
        $retorno = '$("#tpemprst","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'tpemprst') . '");
        			$("#vlemprst","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'vlemprst') . '");
					$("#qtparepr","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'qtparepr') . '");
					$("#cdlcremp","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'cdlcremp') . '");
					$("#dtlibera","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dtlibera') . '");
					$("#dtdpagto","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dtdpagto') . '");
					$("#dslcremp","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dslcremp') . '");
					$("#percetop","#frmSimulacao").val("' . $percetop . '");
					$("#cdfinemp","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'cdfinemp') . '");
                    $("#idcarenc","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'idcarenc') . '");
                    $("#dtcarenc","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dtcarenc') . '");
                    $("#dsfinemp","#frmSimulacao").val("' . getByTagName($dados_simulacao[0]->tags, 'dsfinemp') . '");
                    $("#vliofepr","#frmSimulacao").val("' . $vliofepr  . '");
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
        $retorno .= 'controlaLayoutSimulacoes("' . $operacao . '", "' . $nrsimula . '");hideMsgAguardo();buscadtconsig();';
    }
    echo $retorno;
}
?>