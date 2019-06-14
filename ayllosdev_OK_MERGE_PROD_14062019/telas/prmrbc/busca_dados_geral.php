<?
/*!
 * FONTE        : busca_dados_geral.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Rotina para buscar os dados PRMRBC
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PRMRBC", "CONSPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',"",false);
	}
	
	// Recebendo os valores atraves de atriburos da TAG
	$hrdenvio    = $xmlObjeto->roottag->tags[0]->attributes['HRDENVIO'];
	$hrdreton    = $xmlObjeto->roottag->tags[0]->attributes['HRDRETON'];
	$hrdencer    = $xmlObjeto->roottag->tags[0]->attributes['HRDENCER'];
	$hrdencmx    = $xmlObjeto->roottag->tags[0]->attributes['HRDENCMX'];
	$dsdirarq    = $xmlObjeto->roottag->tags[0]->attributes['DSDIRARQ'];
	$desemail    = $xmlObjeto->roottag->tags[0]->attributes['DESEMAIL'];

	// Exibe os valores na tela
	echo "cHrdenvio.val('".$hrdenvio."');";
	echo "cHrdreton.val('".$hrdreton."');";
	echo "cHrdencer.val('".$hrdencer."');";
	echo "cHrdencmx.val('".$hrdencmx."');";
	echo "cDsdirarq.val('".$dsdirarq."');";
	echo "cDesemail.val('".$desemail."');";

?>