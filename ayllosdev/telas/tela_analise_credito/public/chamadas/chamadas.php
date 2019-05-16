<?php
/**
 * User: Bruno Luiz Katjarowski
 * Date: 05/03/2019
 * Time: 16:29
 * Projeto: ailos_prj438_s9
 */
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('memory_limit', '2048M');

/*
    Ajuste de diretorio conforme configuração de localização da chamada principa
*/
if(isset($configCore)){
    // Includes para controle da session, variáveis globais de controle, e biblioteca de funções
    require_once('../../../includes/config.php');
    require_once('../../../includes/funcoes.php');
    require_once('../../../class/xmlfile.php');
    ini_set('session.cookie_domain', '.cecred.coop.br' );
    session_start();
}else{

    // Includes para controle da session, variáveis globais de controle, e biblioteca de funções
    require_once('../../../../includes/config.php');
    require_once('../../../../includes/funcoes.php');
    require_once('../../../../class/xmlfile.php');
    ini_set('session.cookie_domain', '.cecred.coop.br' );
    session_start();
}
header('Content-Type: text/html; charset=utf-8');

/*
 * CONSTANTES
 * */
define("CODIGO_ID_ORIGEM_CRM",999);
define("TIPO_CHAMADA_AUTENTICA_USUARIO","ATENTICA_USUARIO");
define("TIPO_CHAMADA_GET_XML","GET_XML");


/* Parametros requeridos na chamada $_POST */
$arrParametrosRequeridos = array(
    "cdcooper", //Código da Cooperativa - Viacredi: 1 - Ailos: 3
    "cdagenci", //Codigo da Agência - PA Trabalho
    "cdoperad", //Código do Operador
    "nrcpfcgc", //Número CPF ou CNPJ do Cooperado
    'dstoken'   //Token Ibratan do usuario que estiver logando
);

$dataPost = (object) (isset($configCore) ? $_GET : $_POST);

if(isset($dataPost->configCore)){
	$configCore = $dataPost->configCore;
}

if(isset($_SESSION['glbvars'])){
    $glbvars = $_SESSION['glbvars'];

    if(!isset($glbvars["cdcooper"])){
        $keys = array_keys($_SESSION['glbvars']);
        $glbvars = $_SESSION['glbvars'][$keys[0]];
    }

}else if(isset($dataPost->glbvars)){
	$glbvars = $dataPost->glbvars;
}else{
    $glbvars = Array();
}

$retornoTelaUnica = array();

$localhost = false;
if(isset($configCore)){
    $localhost = $configCore['localhost'];
}

if($localhost){
    switch($dataPost->tipoChamada){
        case TIPO_CHAMADA_AUTENTICA_USUARIO:
            echo validacaoLogin();
            break;
        case TIPO_CHAMADA_GET_XML:
            echo getXml();
            break;
    
    }
}


function validacaoLogin($localhost = false){
    global $retornoTelaUnica, $glbvars;
    if(!$localhost){
        if(efetuaLogin()){
            if(validaToken()){
                return json_encode($retornoTelaUnica);
            }else{
                return json_encode($retornoTelaUnica);
            }
        }else{
            return json_encode($retornoTelaUnica);
        }
    }else{
        $retornoTelaUnica['glbvars'] = $glbvars;
        if(validaToken()){
            return json_encode($retornoTelaUnica);
        }else{
            return json_encode($retornoTelaUnica);
        }
    }
}

function efetuaLogin(){
    global $dataPost, $glbvars, $retornoTelaUnica;


    // Monta o xml de requisição
    $xmlLogin  = "";
    $xmlLogin .= "<Root>";
    $xmlLogin .= "  <Cabecalho>";
    $xmlLogin .= "      <Bo>b1wgen0000.p</Bo>";
    $xmlLogin .= "      <Proc>efetua_login</Proc>";
    $xmlLogin .= "  </Cabecalho>";
    $xmlLogin .= "  <Dados>";
    $xmlLogin .= "      <cdcooper>".$dataPost->cdcooper."</cdcooper>";
    $xmlLogin .= "      <cdagenci>".$dataPost->cdagenci."</cdagenci>";
    $xmlLogin .= "      <nrdcaixa>0</nrdcaixa>";
    $xmlLogin .= "      <cdoperad>".$dataPost->cdoperad."</cdoperad>";
    $xmlLogin .= "      <idorigem>".CODIGO_ID_ORIGEM_CRM."</idorigem>";			// CRM
    $xmlLogin .= "      <vldsenha>no</vldsenha>";
    $xmlLogin .= "      <cddsenha></cddsenha>";
    $xmlLogin .= "      <cdpactra>".$dataPost->cdagenci."</cdpactra>";
    $xmlLogin .= "      <dsdemail></dsdemail>";
    $xmlLogin .= "  </Dados>";
    $xmlLogin .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = getDataXML($xmlLogin,false,true,$dataPost->cdcooper);
    $xmlData = simplexml_load_string($xmlResult);

    if(isset($xmlData->Erro)){
        $retornoTelaUnica['error'] = "1 - ".$xmlData->Erro->Registro->dscritic;
        return false;
    }else if(isset($xmlData->HEAD)){
        $retornoTelaUnica['error'] = "1 - ".$xmlData->HEAD->TITLE;
    }else{

        $dados = $xmlData->Dados->Registro;

        /* RETIRADO DE autenticacao_crm.php na pasta raiz do sistema aimaro */
        $sidlogin = md5(time().uniqid());
        $cdoperad = (string) $dados->cdoperad;

        // Armazena SID para utilizar no momento que a HOME é carregada
        $_SESSION["sidlogin"] = $sidlogin;
        $_SESSION["hrdlogin"] = strtotime("now");

        // Cria array temporário com variáveis globais
        $glbvars["cdcooper"] = $dataPost->cdcooper;
        $glbvars["nmcooper"] = strtolower($dados->nmcooper);
        $glbvars["cdagenci"] = 0;
        $glbvars["nrdcaixa"] = 0;
        $glbvars["cdoperad"] = $cdoperad;
        $glbvars["nmoperad"] = (string) $dados->nmoperad;
        $glbvars["dtmvtolt"] = (string) $dados->dtmvtolt;
        $glbvars["dtmvtopr"] = (string) $dados->dtmvtopr;
        $glbvars["dtmvtoan"] = (string) $dados->dtmvtoan;
        $glbvars["inproces"] = (string) $dados->inproces;
        $glbvars["idorigem"] = 5;
        $glbvars["idsistem"] = 1;
        $glbvars["stimeout"] = (string) $dados->stimeout;
        $glbvars["dsdepart"] = (string) $dados->dsdepart;
        $glbvars["dsdircop"] = (string) $dados->dsdircop;
        $glbvars["hraction"] = strtotime("now");
        $glbvars["flgdsenh"] = (string) $dados->flgdsenh; // Verifica se tem q trocar de senha
        $glbvars["sidlogin"] = $sidlogin;
        $glbvars["cdpactra"] = (string) $dados->cdpactra;
        $glbvars["flgperac"] = (string) $dados->flgperac;
        $glbvars["nvoperad"] = (string) $dados->nvoperad;
        $glbvars["cddepart"] = (string) $dados->cddepart;
        $glbvars["idparame_reciproci"] = 0;
        $glbvars["desretorno"] = "NOK";

        $retornoTelaUnica['glbvars'] = $glbvars;
        return true;
    }
}

function validaToken(){
    global $glbvars,$retornoTelaUnica,$dataPost;

    // Devemos validar o token do operador
    // Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "	<dstoken>".$dataPost->dstoken."</dstoken>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,
        "CADA0011",
        "VALIDA_TOKEN",
        $dataPost->cdcooper,
        $glbvars["cdagenci"],
        $glbvars["nrdcaixa"],
        $glbvars["idorigem"],
        $glbvars["cdoperad"],
        "</Root>");

    // print_r($xmlResult);
    // die();
    // exit();
    $xmlData = simplexml_load_string($xmlResult);


    if(isset($xmlData->Erro)){
        $retornoTelaUnica['error'] = "2 - ".$xmlData->Erro->Registro->dscritic;
        //return false;
    }else{
        $retornoTelaUnica['valida_token'] = is_null($xmlData->Dados->Registro->dstoken) ? true : false;
    }
    return true;
}

/**
 * Recuperar ultimo xml da conta proposta
 * @return string Json
 */
function getXml(){
    global $glbvars,$dataPost;

    // Devemos validar o token do operador
    // Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "    <nrdconta>".$dataPost->nrdconta."</nrdconta>";
    $xml .= "    <tpproduto>".$dataPost->tpproduto."</tpproduto>";
    $xml .= "    <nrcontrato>".$dataPost->nrproposta."</nrcontrato>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,
        "TELA_ANALISE_CREDITO",
        "CONSULTA_XML",
        $dataPost->cdcooper,
        $glbvars["cdagenci"],
        $glbvars["nrdcaixa"],
        $glbvars["idorigem"],
        $glbvars["cdoperad"],
        "</Root>");

    $xmlData = simplexml_load_string($xmlResult);

    $projetos_json = json_encode($xmlData);

    return $projetos_json;
}

function toArray(SimpleXMLElement $xml) {

        $array = (array)$xml;

        foreach ( array_slice($array, 0) as $key => $value ) {
            if ( $value instanceof SimpleXMLElement ) {
                $array[$key] = empty($value) ? NULL : toArray($value);
            }
        }
        return $array;
    }

function objectToArray($object) {
    if(!is_object($object) && !is_array($object))
        return $object;

    return array_map('objectToArray', (array) $object);
}

function validaEntrada($params){
    global $retornoTelaUnica,$arrParametrosRequeridos;
    //VERIFICAR VALIDADE DOS PARAMETROS DE ENTRADA
    if(count($params) > 0){
        foreach($arrParametrosRequeridos as $key){
            if(!key_exists($key,$params)){
                $retornoTelaUnica['error'] = 'Erro ao realizar login - Parametros';
            }
        }
    }else{
        $retornoTelaUnica['error'] = 'Erro ao realizar login - Parametros';
    }
}

/**
 * Verificar se iniciou uma sessão nessa entrada.
 */
function is_session_started()
{
    if ( php_sapi_name() !== 'cli' ) {
        if ( version_compare(phpversion(), '5.4.0', '>=') ) {
            return session_status() === PHP_SESSION_ACTIVE ? TRUE : FALSE;
        } else {
            return session_id() === '' ? FALSE : TRUE;
        }
    }
    return FALSE;
}