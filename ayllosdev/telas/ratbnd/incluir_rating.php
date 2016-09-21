<?
/*!
 * FONTE        : incluir_rating.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/11/2013
 * OBJETIVO     : Incluir registro - Tela RATBND
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

    // Includes para controle da session, variáveis globais de controle, e biblioteca de funções
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");
    require_once("../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo método POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");

    // Recebe as variaveis
    $cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
    $inpessoa	= (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0  ;
    $tppesqui	= (isset($_POST['tppesqui'])) ? $_POST['tppesqui'] : 'C';
    $nrcpfcgc	= (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;
    $vlempbnd	= (isset($_POST['vlempbnd'])) ? $_POST['vlempbnd'] : 0  ;
    $qtparbnd	= (isset($_POST['qtparbnd'])) ? $_POST['qtparbnd'] : 0  ;
    $nrinfcad	= (isset($_POST['nrinfcad'])) ? $_POST['nrinfcad'] : 0  ;
    $nrgarope	= (isset($_POST['nrgarope'])) ? $_POST['nrgarope'] : 0  ;
    $nrliquid	= (isset($_POST['nrliquid'])) ? $_POST['nrliquid'] : 0  ;
    $nrpatrim	= (isset($_POST['nrpatrim'])) ? $_POST['nrpatrim'] : 0  ;
    $nrperger	= (isset($_POST['nrperger'])) ? $_POST['nrperger'] : 0  ;
    $nrctrato	= (isset($_POST['nrctrato'])) ? $_POST['nrctrato'] : 0  ;
    $inconfir	= (isset($_POST['inconfir'])) ? $_POST['inconfir'] : 0  ;

    $retornoAposErro = 'focaCampoErro(\'nrinfcad\', \'frmDetalhe\');';

    //Monta o xml de requisição
    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
        exibeErro($msgError);
    }

    // Monta o xml de requisição
    $xmlContrato  = '';
    $xmlContrato .= '<Root>';
    $xmlContrato .= '	<Cabecalho>';
    $xmlContrato .= '		<Bo>b1wgen0157.p</Bo>';
    $xmlContrato .= '		<Proc>incluir-rating-bndes</Proc>';
    $xmlContrato .= '	</Cabecalho>';
    $xmlContrato .= '	<Dados>';
    $xmlContrato .=	'       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xmlContrato .=	'       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xmlContrato .=	'       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xmlContrato .=	'       <inproces>'.$glbvars['inproces'].'</inproces>';
    $xmlContrato .=	'       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
    $xmlContrato .=	'       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xmlContrato .=	'       <inpessoa>'.$inpessoa.'</inpessoa>';
    $xmlContrato .=	'       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
    $xmlContrato .=	'       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
    $xmlContrato .=	'       <tppesqui>'.$tppesqui.'</tppesqui>';
    $xmlContrato .=	'       <vlempbnd>'.$vlempbnd.'</vlempbnd>';
    $xmlContrato .=	'       <qtparbnd>'.$qtparbnd.'</qtparbnd>';
    $xmlContrato .=	'       <nrinfcad>'.$nrinfcad.'</nrinfcad>';
    $xmlContrato .=	'       <nrgarope>'.$nrgarope.'</nrgarope>';
    $xmlContrato .=	'       <nrliquid>'.$nrliquid.'</nrliquid>';
    $xmlContrato .=	'       <nrpatlvr>'.$nrpatrim.'</nrpatlvr>';
    $xmlContrato .=	'       <nrperger>'.$nrperger.'</nrperger>';
    $xmlContrato .=	'       <inconfir>'.$inconfir.'</inconfir>';
    $xmlContrato .=	'       <nrctrato>'.$nrctrato.'</nrctrato>';
    $xmlContrato .= '	</Dados>';
    $xmlContrato .= '</Root>';

    // Executa script para envio do XML
    $xmlResult = getDataXML($xmlContrato);

    // Cria objeto para classe de tratamento de XML
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msg = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msg,'Alerta - Ayllos',$retornoAposErro,false);
        exit();
    }

	// Guarda o numero do contrato para mostra ao usuário
    $nvctrato = $xmlObjeto->roottag->tags[0]->attributes["NRCTRATO"];

	// Carrega a informação do Risco Proposto
    $dssitcrt = "RISCO PROPOSTO: ".$xmlObjeto->roottag->tags[0]->attributes["DSDRISCO"];

	// Exibe o numero do novo contrato e a situação do risco
    include('form_situacao.php');
?>