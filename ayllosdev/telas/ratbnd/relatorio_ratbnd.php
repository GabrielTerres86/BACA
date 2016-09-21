<?
/*!
 * FONTE        : relatorio_ratbnd.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : 22/11/2013
 * OBJETIVO     : Relat�rio - Tela RATBND
 * --------------
 * ALTERA��ES   :
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

    // Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");
    require_once("../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo m�todo POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");

    // Recebe as variaveis
    $cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
    $tppesqui	= (isset($_POST['tppesqui'])) ? $_POST['tppesqui'] : 'C';
    $cdagenci	= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0  ;
    $dtiniper	= (isset($_POST['dtiniper'])) ? $_POST['dtiniper'] : 0  ;
    $dtfimper	= (isset($_POST['dtfimper'])) ? $_POST['dtfimper'] : 0  ;
    $tprelato	= (isset($_POST['tprelato'])) ? $_POST['tprelato'] : 'S';

    $retornoAposErro = 'focaCampoErro(\'nrinfcad\', \'frmDetalhe\');';

    //Monta o xml de requisi��o
    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
        exibeErro($msgError);
    }

    // Monta o xml de requisi��o
    $xmlContrato  = '';
    $xmlContrato .= '<Root>';
    $xmlContrato .= '	<Cabecalho>';
    $xmlContrato .= '		<Bo>b1wgen0157.p</Bo>';
    $xmlContrato .= '		<Proc>impressao-rating</Proc>';
    $xmlContrato .= '	</Cabecalho>';
    $xmlContrato .= '	<Dados>';
    $xmlContrato .=	'       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xmlContrato .=	'       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
    $xmlContrato .=	'       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xmlContrato .=	'       <cdagenci>'.$cdagenci.'</cdagenci>';
    $xmlContrato .=	'       <tppesqui>'.$tppesqui.'</tppesqui>';
    $xmlContrato .=	'       <dtiniper>'.$dtiniper.'</dtiniper>';
    $xmlContrato .=	'       <dtfimper>'.$dtfimper.'</dtfimper>';
    $xmlContrato .=	'       <tprelato>'.$tprelato.'</tprelato>';
    $xmlContrato .= '	</Dados>';
    $xmlContrato .= '</Root>';

    // Executa script para envio do XML
    $xmlResult = getDataXML($xmlContrato);

    // Cria objeto para classe de tratamento de XML
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra cr�tica
    if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
        $msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
    }

    if ($tprelato == "S") { // Se for sem rating efetivo

        // Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
        $nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];

        // Chama fun��o para mostrar PDF do impresso gerado no browser
        visualizaPDF($nmarqpdf);

    }else
    if ($tprelato == "R") { // Se for Opera��es BNDES

        $contrato  = $xmlObjeto->roottag->tags[0]->tags;

        include('tab_contrato.php'); // Mostra os contratos em tabela
    }
?>