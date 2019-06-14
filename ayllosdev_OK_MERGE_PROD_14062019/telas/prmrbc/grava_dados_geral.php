<?
/*!
 * FONTE        : grava_dados_geral.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Rotina para gravar os dados PRMRBC
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

	// Recebe o POST
	$hrdenvio    = (isset($_POST['hrdenvio'])) ? $_POST['hrdenvio'] : ' '  ;
	$hrdreton    = (isset($_POST['hrdreton'])) ? $_POST['hrdreton'] : ' '  ;
	$hrdencer    = (isset($_POST['hrdencer'])) ? $_POST['hrdencer'] : ' '  ;
	$hrdencmx    = (isset($_POST['hrdencmx'])) ? $_POST['hrdencmx'] : ' '  ;
	$dsdirarq    = (isset($_POST['dsdirarq'])) ? $_POST['dsdirarq'] : ' '  ;
	$desemail    = (isset($_POST['desemail'])) ? $_POST['desemail'] : ' '  ;

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
	$xml .= '		<hrdenvio>'.$hrdenvio.'</hrdenvio>';
	$xml .= '		<hrdreton>'.$hrdreton.'</hrdreton>';
	$xml .= '		<hrdencer>'.$hrdencer.'</hrdencer>';
	$xml .= '		<hrdencmx>'.$hrdencmx.'</hrdencmx>';
	$xml .= '		<dsdirarq>'.$dsdirarq.'</dsdirarq>';
	$xml .= '		<desemail>'.$desemail.'</desemail>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PRMRBC", "GRVPARM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',"",false);
	}

?>