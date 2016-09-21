<?
/*!
 * FONTE        : DEVOLU.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : 25/09/2013
 * OBJETIVO     : Requisi��o da tela DEVOLU
 * --------------
 * ALTERA��ES   :
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

    // Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Inicializa
	$retornoAposErro = '';

    $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ;
    $dsbccxlt = (isset($_POST['dsbccxlt'])) ? $_POST['dsbccxlt'] : 0  ;
    $nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0  ;
    $nrdctitg = (isset($_POST['nrdctitg'])) ? $_POST['nrdctitg'] : 0  ;
    $cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : 0  ;
    $cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : 0  ;
    $nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0  ;
    $cddsitua = (isset($_POST['cddsitua'])) ? $_POST['cddsitua'] : 0  ;
    $nrdrecid = (isset($_POST['nrdrecid'])) ? $_POST['nrdrecid'] : 0  ;
    $vllanmto = (isset($_POST['vllanmto'])) ? $_POST['vllanmto'] : 0  ;
    $flag = (isset($_POST['flag'])) ? $_POST['flag'] : 0  ;

	$retornoAposErro = 'focaCampoErro(\'cdalinea\', \'frmAlinea\');';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"D")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml din�mico de acordo com a opera��o
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0175.p</Bo>';
	$xml .= '		<Proc>verifica-folha-cheque</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
    $xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdcooper>'.$cdcooper.'</cdcooper>';
	$xml .= '		<nrctachq>'.$nrctachq.'</nrctachq>';
	$xml .= '		<dsbccxlt>'.$dsbccxlt.'</dsbccxlt>';
	$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';
	$xml .= '		<nrdctitg>'.$nrdctitg.'</nrdctitg>';
	$xml .= '		<cdbanchq>'.$cdbanchq.'</cdbanchq>';
	$xml .= '		<cdagechq>'.$cdagechq.'</cdagechq>';
	$xml .= '		<cddsitua>'.$cddsitua.'</cddsitua>';
	$xml .= '		<nrdrecid>'.$nrdrecid.'</nrdrecid>';
	$xml .= '		<vllanmto>'.$vllanmto.'</vllanmto>';
	$xml .= '		<flag>'.$flag.'</flag>';
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