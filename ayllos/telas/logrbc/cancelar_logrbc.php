<?
/*!
 * FONTE        : cancelar_logrbc.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Novembro/2014
 * OBJETIVO     : Rotina para efetuar o cancelamento de dados LOGRBC
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	$retornoAposErro = '';

	// Recebe o POST
	$rowid = (isset($_POST['rowid'])) ? $_POST['rowid'] : ''  ;
	$dsmotcan = (isset($_POST['dsmotcan'])) ? $_POST['dsmotcan'] : '' ;
	$nmarqcan = (isset($_POST['nmarqcan'])) ? $_POST['nmarqcan'] : '' ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'X')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<rowid>'.$rowid.'</rowid>';
	$xml .= '		<dsmotcan><![CDATA[ '.$dsmotcan.' ]]></dsmotcan>';
	$xml .= '		<nmarqcan>'.$nmarqcan.'</nmarqcan>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "LOGRBC", "CANCREM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
?>