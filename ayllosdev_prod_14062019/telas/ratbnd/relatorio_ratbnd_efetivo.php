<?
/*!
 * FONTE        : relatorio_rating_efetivo.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/11/2013
 * OBJETIVO     : Relatório - Tela RATBND
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
    $nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
    $tpctrato	= (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : 0 ;
    $nrctrato	= (isset($_POST['nrctrato'])) ? $_POST['nrctrato'] : 0 ;
    $cdoperad	= (isset($_POST['cdoperad'])) ? $_POST['cdoperad'] : 0 ;

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
    $xmlContrato .= '		<Proc>imprimir-ratbnd-efetivos</Proc>';
    $xmlContrato .= '	</Cabecalho>';
    $xmlContrato .= '	<Dados>';
    $xmlContrato .=	'       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xmlContrato .=	'       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
    $xmlContrato .=	'       <dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
    $xmlContrato .=	'       <inproces>'.$glbvars['inproces'].'</inproces>';
    $xmlContrato .=	'       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xmlContrato .=	'       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xmlContrato .=	'       <tpctrato>'.$tpctrato.'</tpctrato>';
    $xmlContrato .=	'       <nrctrato>'.$nrctrato.'</nrctrato>';
    $xmlContrato .=	'       <cdoperad>'.$cdoperad.'</cdoperad>';
    $xmlContrato .= '	</Dados>';
    $xmlContrato .= '</Root>';

    // Executa script para envio do XML
    $xmlResult = getDataXML($xmlContrato);

    // Cria objeto para classe de tratamento de XML
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
        $msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
    }

    // Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    $nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];

	echo 'bloqueiaFundo($(\'#divRotina\'));';

    // Chama função para mostrar PDF do impresso gerado no browser
    visualizaPDF($nmarqpdf);

?>