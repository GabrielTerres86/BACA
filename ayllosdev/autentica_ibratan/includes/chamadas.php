<?php
/**
 * User: Bruno Luiz Katjarowski
 * Date: 18/03/2019
 * Time: 14:02
 * Projeto: autentica_tela_unica
 */
/** @var Autentica $autentica */
require_once('../includes/config.php');
require_once('../includes/funcoes.php');
require_once('../class/xmlfile.php');
ini_set('session.cookie_domain', '.cecred.coop.br' );
session_start();
$glbvars = null;
/**
 * Redirecionar para outra página com dados de $_POST
 *
 * @param string $url URL.
 * @param array $post_data POST data. Example: array('foo' => 'var', 'id' => 123)
 * @param array $headers Optional. Extra headers to send.
 */
function redirect_post($url, array $data, array $headers = null) {
    $params = array(
        'http' => array(
            'method' => 'POST',
            'content' => http_build_query($data)
        )
    );
    if (!is_null($headers)) {
        $params['http']['header'] = '';
        foreach ($headers as $k => $v) {
            $params['http']['header'] .= "$k: $v\n";
        }
    }
    var_dump($params);
    $ctx = stream_context_create($params);
    $fp = @fopen($url, 'rb', false, $ctx);
    if ($fp) {
        echo @stream_get_contents($fp);
        die();
    } else {
        // Error
        throw new Exception("Erro ao carregar '$url', $php_errormsg");
    }
}

function efetuaLogin(){
    global $autentica, $retornoTelaUnica, $glbvars;
    //unset($_SESSION['glbvars']);
    if(!isset($_SESSION['glbvars'])){
        // Monta o xml de requisição
        $xmlLogin  = "";
        $xmlLogin .= "<Root>";
        $xmlLogin .= "  <Cabecalho>";
        $xmlLogin .= "      <Bo>b1wgen0000.p</Bo>";
        $xmlLogin .= "      <Proc>efetua_login</Proc>";
        $xmlLogin .= "  </Cabecalho>";
        $xmlLogin .= "  <Dados>";
        $xmlLogin .= "      <cdcooper>".$autentica->getCdcooper()."</cdcooper>";
        $xmlLogin .= "      <cdagenci>".$autentica->getCdagenci()."</cdagenci>";
        $xmlLogin .= "      <nrdcaixa>0</nrdcaixa>";
        $xmlLogin .= "      <cdoperad>".$autentica->getCdoperad()."</cdoperad>";
        $xmlLogin .= "      <idorigem>999</idorigem>";			// CRM
        $xmlLogin .= "      <vldsenha>no</vldsenha>";
        $xmlLogin .= "      <cddsenha></cddsenha>";
        $xmlLogin .= "      <cdpactra>".$autentica->getCdagenci()."</cdpactra>";
        $xmlLogin .= "      <dsdemail></dsdemail>";
        $xmlLogin .= "  </Dados>";
        $xmlLogin .= "</Root>";
    
        // Executa script para envio do XML
        $xmlResult = getDataXML($xmlLogin,false,true,$autentica->getCdcooper());
        $xmlData = simplexml_load_string($xmlResult);
    
        if(isset($xmlData->Erro)){
            $retornoTelaUnica['error'] = "1 - ".$xmlData->Erro->Registro->dscritic;
            return false;
        }else if(isset($xmlData->HEAD)){
            $retornoTelaUnica['error'] = "1.1 - ".$xmlData->HEAD->TITLE." (esquema holder)<br>";
            return false;
        }else{
    
            $dados = $xmlData->Dados->Registro;
    
            /* RETIRADO DE autenticacao_crm.php na pasta raiz do sistema aimaro */
            $sidlogin = md5(time().uniqid());
            $cdoperad = (string) $dados->cdoperad;
    
            // Armazena SID para utilizar no momento que a HOME é carregada
            $_SESSION["sidlogin"] = $sidlogin;
            $_SESSION["hrdlogin"] = strtotime("now");
    
            // Cria array temporário com variáveis globais
            $glbvars["cdcooper"] = $autentica->getCdcooper();
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
    
            $_SESSION["glbvars"][$sidlogin] = $glbvars;
            $retornoTelaUnica['glbvars'] = $glbvars;
            return true;
        }
    }else{
        $retornoTelaUnica['glbvars'] = $_SESSION['glbvars'];
        return true;
    }
    return false;
}

function validarPermissao($nmdatela,$nmrotina,$cddopcao='') {
    global $autentica, $glbvars;
    $vars = getGlbVars($_SESSION);
    	
    // Monta o xml de requisi��o
    $xmlGetPermis  = "";
    $xmlGetPermis .= "<Root>";
    $xmlGetPermis .= "	<Cabecalho>";
    $xmlGetPermis .= "		<Bo>b1wgen0000.p</Bo>";
    $xmlGetPermis .= "		<Proc>obtem_permissao</Proc>";
    $xmlGetPermis .= "	</Cabecalho>";
    $xmlGetPermis .= "	<Dados>";
    $xmlGetPermis .= "		<cdcooper>".$autentica->getCdcooper()."</cdcooper>";
    $xmlGetPermis .= "		<cdagenci>".$autentica->getCdagenci()."</cdagenci>";
    $xmlGetPermis .= "		<nrdcaixa>".$vars["nrdcaixa"]."</nrdcaixa>";
    $xmlGetPermis .= "		<cdoperad>".$autentica->getCdoperad()."</cdoperad>";
    $xmlGetPermis .= "		<idorigem>".$vars["idorigem"]."</idorigem>";
    $xmlGetPermis .= "		<idsistem>".$vars["idsistem"]."</idsistem>";
    $xmlGetPermis .= "		<nmdatela>".$nmdatela."</nmdatela>";
    $xmlGetPermis .= "		<nmrotina>".$nmrotina."</nmrotina>";
    $xmlGetPermis .= "		<cddopcao>".$cddopcao."</cddopcao>";
    $xmlGetPermis .= "		<inproces>".$vars["inproces"]."</inproces>";
    $xmlGetPermis .= "	</Dados>";
    $xmlGetPermis .= "</Root>";
    
    // Executa script para envio do XML
    $xmlResult = getDataXML($xmlGetPermis);
    
    // Cria objeto para classe de tratamento de XML
    $xmlObjPermis = getObjectXML($xmlResult);
    
    // Se BO retornou algum erro, redireciona para home
    if (strtoupper($xmlObjPermis->roottag->tags[0]->name) == "ERRO") {
        return '6 - '.$xmlObjPermis->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
	return "";
}

function validaToken(){
    global $glbvars,$autentica,$retornoTelaUnica;
    
    // Devemos validar o token do operador
    // Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "	<dstoken>".$autentica->dstoken."</dstoken>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,
        "CADA0011",
        "VALIDA_TOKEN",
        $glbvars["cdcooper"],
        $glbvars["cdagenci"],
        $glbvars["nrdcaixa"],
        $glbvars["idorigem"],
        $glbvars["cdoperad"],
        "</Root>");

    $xmlData = simplexml_load_string($xmlResult);


    if(isset($xmlData->Erro)){
        $retornoTelaUnica['error'] = "2 - ".$xmlData->Erro->Registro->dscritic;
        return false;
    }else{
        $retornoTelaUnica['valida_token'] = is_null($xmlData->Dados->Registro->dstoken) ? true : false;
    }
    return true;
}

function validaEntradaUsuario(){
    global $retornoTelaUnica,$autentica;
    if(is_session_started()){
        if(isset($_SESSION['tipoEntrada'])){
            $autentica->setTipoEntrada($_SESSION['tipoEntrada']);

            /**
             *  Somente ocorre quando usuario tentar entrar diretamente no link de redirecionamento para a tela de analise de crédito
             */
            if($autentica->getTipoEntrada() === 'NOK'){
                $retornoTelaUnica['error'] = '4 - Usuário não possui permissão de acesso.';
                return false;
            }

            /** 
             * TAG especial para testes de desenvolvimento
             * testes/telaunica/index.php -> Redireciona para esta pasta (autentica_ibratan) com a $_SESSION tipoEntrada
             */
            if($autentica->getTipoEntrada() === 'homol_autentica'){
                return true;
            }
        }
    }
    return true;
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

/**
 * Retornar se está em ambiente de dev
 * @return boolean
 */
function isDev(){
    //Na tela de teste/telaunica enviar ?dev=dev
    //Fazer testes de debug aqui;
    if(isset($_SESSION['dev'])){
        if($_SESSION['dev']){
            return true;
        }
    }
    return false;
}

/**
 * Recuerar glbvars dentro da $_SESSION
 *
 * @param array $s Variaveis contendo a sessão atual
 * @return array
 */
function getGlbVars($s){
    $glbvars = $_SESSION['glbvars'];
    $keys = array_keys($glbvars);
    $glbvars = $glbvars[$keys[0]];
    return $glbvars;
}