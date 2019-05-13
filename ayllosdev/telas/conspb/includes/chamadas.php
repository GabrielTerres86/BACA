<?
/*
Autor: Bruno Luiz Katzjarowski - Mouts;
Data: 12/03/2019
Ultima alteração:
*/

include('requires.php');

error_reporting(E_ALL);
ini_set('display_errors', 1);

$data = (object) $_POST;
$retorno = Array();

define("CONSULTAR_AGEND_CON","CONSULTAR_AGEND_CON");
define("ALTERAR_AGEND_CONCILIACAO","ALTERAR_AGEND_CONCILIACAO");
define("EXECUTA_CONCILIACAO_MANUAL","EXECUTA_CONCILIACAO_MANUAL");

//pc_alterar_agend_conciliacao
//pc_consultar_agend_con

switch($data->chamada){
    case CONSULTAR_AGEND_CON:
        echo json_encode(consultarOpcaoA((object) $data->parametros));
        break;
    
    case ALTERAR_AGEND_CONCILIACAO:
        echo json_encode(alterarOpcaoA((object) $data->parametros));
        break;

    case EXECUTA_CONCILIACAO_MANUAL:
        echo json_encode(executarConciliacao((object) $data->parametros));
        break;
}

/**
 * Retorna dados para a opação A
 * @return string
 */
function consultarOpcaoA($parametros){
    global $glbvars, $retorno;
    
    $xml  = "";
    $xml .= "<Root>";
    $xml .= "	<Dados>";
    $xml .= "		<cddopcao>".(string) $parametros->cddopcao."</cddopcao>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";
    //pr_nrseq_mensagem,pr_idorigem
            
    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_CONSPB", "PC_CONSULTAR_AGEND_CON", 
                            $glbvars["cdcooper"], 
                            $glbvars["cdagenci"], 
                            $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = simplexml_load_string($xmlResult);

    $json = json_encode($xmlObj);
    $jsonReturn = json_decode($json,TRUE);

    $retorno['retorno'] = $jsonReturn;

    tratarErro($xmlObj);
    return $retorno;
}

function alterarOpcaoA($parametros){
    global $glbvars, $retorno;
    
    $xml  = "";
    $xml .= "<Root>";
    $xml .= "	<Dados>";
    $xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "		<dhagendcon>".str_replace(':','',$parametros->dhagendcon)."</dhagendcon>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";
    //pr_nrseq_mensagem,pr_idorigem
            
    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_CONSPB", "PC_ALTERAR_AGEND_CONCILIACAO", 
                            $glbvars["cdcooper"], 
                            $glbvars["cdagenci"], 
                            $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = simplexml_load_string($xmlResult);

    $json = json_encode($xmlObj);
    $jsonReturn = json_decode($json,TRUE);

    $retorno['retorno'] = $jsonReturn;

    tratarErro($xmlObj);
    return $retorno;
}

function executarConciliacao($parametros){
    global $glbvars, $retorno;
    
    $xml  = "";
    $xml .= "<Root>";
    $xml .= "	<Dados>";
    $xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .="        <tipo_msg>".      $parametros->horarioOpcao."</tipo_msg>";
    $xml .="        <dtmensagem_de>". $parametros->periodoDe."</dtmensagem_de>";
    $xml .="        <dtmensagem_ate>".$parametros->periodoAte."</dtmensagem_ate>";
    $xml .= "       <dsendere>".      $parametros->dsendere."</dsendere>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";
                
    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_CONSPB", "PC_EXECUTAR_CONCILIACAO_MNL", 
                            $glbvars["cdcooper"], 
                            $glbvars["cdagenci"], 
                            $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = simplexml_load_string($xmlResult);

    $json = json_encode($xmlObj);
    $jsonReturn = json_decode($json,TRUE);

    $retorno['retorno'] = $jsonReturn;

    tratarErro($xmlObj);
    return $retorno;
}

/**
 * Undocumented function
 *
 * @param [type] $xmlObj
 * @return void
 */
function tratarErro($xmlObj){
	global $retorno;
	//se ocorreu erro no retorno da proc
	if(property_exists($xmlObj, 'Erro')){
		$codError = $xmlObj->Erro->Registro->cdcritic;		
		if(isset($codError)){
			$msg = trim(preg_replace('/\s\s+/', ' ', $xmlObj->Erro->Registro->dscritic));
			$retorno['erro'] = $xmlObj;
		}
	}
}