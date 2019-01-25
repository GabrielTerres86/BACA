<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Requisição da tela DEVOLU
 * --------------
 * ALTERAÇÕES   : 09/11/2016 - Remover validação de permissao nas telas secundares (Lucas Ranghetti #544579)
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

	// Monta o xml dinâmico de acordo com a operação
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
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	}
?>