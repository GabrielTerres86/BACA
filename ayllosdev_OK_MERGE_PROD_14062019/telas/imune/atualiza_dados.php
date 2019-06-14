<?
/*!
 * FONTE        : IMUNE.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 19/07/2013
 * OBJETIVO     : Requisição Atualização da tela IMUNE
 * --------------
 * ALTERAÇÕES   : 30/10/2013 - Incluir campo $cddopcao (Lucas R.)
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
	$nrcpfcgc		= (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;
    $cdsitcad		= (isset($_POST['cdsitcad'])) ? $_POST['cdsitcad'] : 0  ;
    $dscancel		= (isset($_POST['dscancel'])) ? $_POST['dscancel'] : '' ;
	$cddopcao       = $_POST['cddopcao'];

    $retornoAposErro = 'focaCampoErro(\'cdsitcad\', \'frmDados\');';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0159.p</Bo>';
	$xml .= '		<Proc>altera-imunidade</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<cdsitcad>'.$cdsitcad.'</cdsitcad>';
	$xml .= '		<dscancel>'.$dscancel.'</dscancel>';
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

?>