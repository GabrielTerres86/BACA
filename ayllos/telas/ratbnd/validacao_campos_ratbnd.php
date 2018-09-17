<?
/*!
 * FONTE        : validacao_campos_ratbnd.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/11/2013
 * OBJETIVO     : Validação dos campos de detalhes - Tela RATBND
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
    $nrpatlvr	= (isset($_POST['nrpatlvr'])) ? $_POST['nrpatlvr'] : 0  ;
    $nrperger	= (isset($_POST['nrperger'])) ? $_POST['nrperger'] : 0  ;

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
    $xmlContrato .= '		<Proc>validacao-campos-ratbnd</Proc>';
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
    $xmlContrato .=	'       <nrpatlvr>'.$nrpatlvr.'</nrpatlvr>';
    $xmlContrato .=	'       <nrperger>'.$nrperger.'</nrperger>';
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

?>