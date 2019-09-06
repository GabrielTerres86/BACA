<?php
/*!
 * FONTE        : valida_feriado.php
 * CRIAÇÃO      : Michel Candido         
 * DATA CRIAÇÃO : 30/08/2013
 * OBJETIVO     : Validacao da data
 * --------------
 * ALTERAÇÕES   : 18/05/2016 - Correcao para filtrar corretamente o feriado. (Jaison/Marcos)
 *				  28/07/2016 - Removi o comando session_start e validei os indices do XML. SD 491925. (Carlos R.)
 * --------------
 */

// Includes para variáveis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
require_once("../../class/xmlfile.php");
isPostMethod();

function valida_feriado($glb_dtmvtolt, $dataCalc, $arrayParam) {
    list($dia, $mes, $ano) = explode('/',$glb_dtmvtolt);
    $ultimo_dia = date("t", mktime(0,0,0,$mes,'01',$ano));
    $i = 0;
    while ($dataCalc > 0) { //enquanto data for maior que 0 subtrai 1 dia data

        $data = date('w d/m/Y',strtotime("-$i days",mktime(0,0,0,$mes,$ultimo_dia,$ano)));
        $i++;
        $cdAcesso = substr($data,2); 
        $diaSemana = substr($data,0,1);

        if ($diaSemana > 0 && $diaSemana < 6) {

            $xml  = "";
            $xml .= "<Root>";
            $xml .= "  <Cabecalho>";
            $xml .= "	    <Bo>b1wgen0166.p</Bo>";
            $xml .= "        <Proc>Valida_feriado</Proc>";
            $xml .= "  </Cabecalho>";
            $xml .= "  <Dados>";
            $xml .= "        <cdcooper>".$arrayParam["cdcooper"]."</cdcooper>";
            $xml .= "        <cdagenci>".$arrayParam["cdagenci"]."</cdagenci>";
            $xml .= "        <nrdcaixa>".$arrayParam["nrdcaixa"]."</nrdcaixa>";
            $xml .= "        <cdoperad>".$arrayParam["cdoperad"]."</cdoperad>";
            $xml .= "        <dtmvtolt>".$arrayParam["dtmvtolt"]."</dtmvtolt>";
            $xml .= "        <idorigem>".$arrayParam["idorigem"]."</idorigem>";
            $xml .= "        <nmdatela>".$arrayParam["nmdatela"]."</nmdatela>";
            $xml .= "        <cdprogra>".$arrayParam["cdprogra"]."</cdprogra>";
            $xml .= '        <dtferiad>'.substr($data,1).'</dtferiad>';
            $xml .= "  </Dados>";
            $xml .= "</Root>";

            // Executa script para envio do XML
            $xmlResult = getDataXML($xml);

            // Cria objeto para classe de tratamento de XML
            $xmlObj = getObjectXML($xmlResult);

            if ( isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
                exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
            }

            $registros = ( isset($xmlObj->roottag->tags[0]) ) ? $xmlObj->roottag->tags[0] : array();

            if(isset($registros->attributes['FERIAD']) && strtolower($registros->attributes['FERIAD']) == 'no'){
                $dataCalc--;
            }

            $dtretorno = substr($data,1);
        }
    }
    return $dtretorno;
}