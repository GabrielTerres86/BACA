<?php
/**
 * Autor: Bruno Luiz Katzjarowski
 * Data: 14/01/2019
 * Ultima alteração:
 * 
 * Alterações:
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');
	require_once('funcoes_autorizacao.php');
isPostMethod();		

$nrdconta   = (isset($_POST["nrdconta"]))   ? $_POST["nrdconta"]   : "";
$cdtippro   = (isset($_POST["cdtippro"]))   ? $_POST["cdtippro"]   : ""; //tpcontrato
$nrcontrato = (isset($_POST["nrcontrato"])) ? $_POST["nrcontrato"] : "";
$vlcontrato = (isset($_POST["vlcontrato"])) ? $_POST["vlcontrato"] : "";
$contas_digitadas = (isset($_POST["contas_digitadas"])) ? $_POST["contas_digitadas"] : "";

//bruno
    $dsComplemento = (isset($_POST["dscomplemento"])) ? $_POST["dscomplemento"] : "";

$funcaoImpressao = (isset($_POST["funcaoImpressao"])) ? $_POST["funcaoImpressao"] : "";
$funcaoGeraProtocolo = (isset($_POST["funcaoGeraProtocolo"])) ? $_POST["funcaoGeraProtocolo"] : "";

    $arrayDctror = (isset($_POST["auxArrayDctror"])) ? $_POST["auxArrayDctror"] : Array();
    $arrayMantal = (isset($_POST["auxArrayMantal"])) ? $_POST["auxArrayMantal"] : Array();
    $codTela = (isset($_POST["codTela"])) ? $_POST["codTela"] : 0;
    $cdopcao_dctror = (isset($_POST["cdopcao_dctror"])) ? $_POST["cdopcao_dctror"] : "";
    $cdopcao_mantal = (isset($_POST["cdopcao_mantal"])) ? $_POST["cdopcao_mantal"] : "";

if(strpos(";",$funcaoImpressao) === false){
    $funcaoImpressao .= ";";
}

/**
 * pr_nrdconta             --> Número da conta
 * pr_cdtippro             --> Código de Operacao (tipo do contrato)
 * pr_dhcontrato           --> Hora de criação do contrato (hora do sistema)
 * pr_nrcontrato           --> Número do COntrato
 * pr_vlcontrato           --> Valor do Contrato
 * pr_cdtransacao_pendente --> Código de transação Pendente
 * pr_contas_digitadas     --> Concatenação das contas digitadas
 */

    if($codTela == "0"){
        geraProtocoloPJ($nrcontrato,$vlcontrato);
    }else{

        switch ($codTela) {
            case '30': //DCTRORS
                if(count($arrayDctror) == 0){
                    geraProtocoloPJ($nrcontrato,$vlcontrato,$contas_digitadas,$dsComplemento);
                }else{
                foreach($arrayDctror as $key => $dados){
                    $dsComplemento = getDscomplementoDctror($cdopcao_dctror,$dados);
                    geraProtocoloPJ($nrcontrato,$vlcontrato,$contas_digitadas,$dsComplemento);
                }
                }
                break;
            case '31': //MANTAL                
                if(count($arrayMantal) == 0){
                    geraProtocoloPJ($nrcontrato,$vlcontrato,$contas_digitadas,$dsComplemento);
                }else{
                foreach($arrayMantal as $key => $dados){
                    $dsComplemento = getDscomplementoMantal($dados);
                    geraProtocoloPJ($nrcontrato,$vlcontrato,$contas_digitadas,$dsComplemento);
                    }
                }
                break;
        }
    }

    $executar = 'fechaRotina($(\'#divUsoGenerico\'));'.($funcaoGeraProtocolo != "" ? $funcaoGeraProtocolo : '');

    exibirErro('inform','Gerado protocolo para operação solicitada!','Alerta - Aimaro',$executar, false); //.$funcaoImpressao


    function geraProtocoloPJ($nrcontrato, $vlcontrato, $contas_digitadas,  $dscomplemento){
        global $glbvars, $cdtippro, $nrdconta;

        $vlcontrato = str_replace(',','.',str_replace('.','',$vlcontrato));

// Montar o xml de Requisicao
$xml = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "    <cdtippro>" . $cdtippro . "</cdtippro>";
$xml .= "    <dhcontrato></dhcontrato>";
$xml .= "    <nrcontrato>" . $nrcontrato . "</nrcontrato>";
$xml .= "    <vlcontrato>" . $vlcontrato . "</vlcontrato>";
$xml .= "    <cdtransacao_pendente></cdtransacao_pendente>"; //Manter Nulo
$xml .= "    <contas_digitadas>".$contas_digitadas."</contas_digitadas>";
$xml .= "    <cdcooper_tel></cdcooper_tel>"; //Manter Nulo

//bruno
if($cdtippro == "31" || $cdtippro == "30"){
    $xml .= "    <dscomplemento>".$dscomplemento."</dscomplemento>"; //Manter Nulo
}

$xml .= "  </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CNTR0001", "GERA_PROTOCOLO_CTD_PJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = simplexml_load_string($xmlResult);

if ($xmlObject->Erro->Registro->dscritic != '') {
    $msgErro = utf8ToHtml($xmlObject->Erro->Registro->dscritic);
    exibirErro('error',$msgErro,'Alerta - Aimaro','', false);
    exit(); 
}
    }

?>