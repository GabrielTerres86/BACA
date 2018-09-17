<?
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Requisição da tela LISTAL
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');

    // Verifica se tela foi chamada pelo método POST
	isPostMethod();

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Inicializa
	$retornoAposErro = '';

	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'T' ;
	$cdcooper		= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0 ;
    $insitreq		= (isset($_POST['insitreq'])) ? $_POST['insitreq'] : 2 ;
    $tprequis		= (isset($_POST['tprequis'])) ? $_POST['tprequis'] : 5 ;
    $dtinicio		= (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '' ;
    $dttermin		= (isset($_POST['dttermin'])) ? $_POST['dttermin'] : '' ;

    //$retornoAposErro = 'focaCampoErro(\'insitreq\', \'frmCab\');';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen9999.p</Bo>';
	$xml .= '		<Proc>listal-consulta-cheques</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
    $xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
    $xml .= '		<cdcoptel>'.$cdcooper.'</cdcoptel>';
	$xml .= '		<insitreq>'.$insitreq.'</insitreq>';
	$xml .= '		<tprequis>'.$tprequis.'</tprequis>';
    $xml .= '		<dtinicio>'.$dtinicio.'</dtinicio>';
    $xml .= '		<dttermin>'.$dttermin.'</dttermin>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

    // ----------------------------------------------------------------------------------------------------------------------------------
	// Controle de Erros
	// ----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

    $registros = $xmlObjeto->roottag->tags[0]->tags;
    //$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
    include('tab_listal.php');

?>