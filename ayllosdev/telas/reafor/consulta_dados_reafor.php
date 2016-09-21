<?
/*!
 * FONTE        : contalta_dados_reafor.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Outubro/2014
 * OBJETIVO     : Rotina para consultar dados REAFOR
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

	$retornoAposErro = 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));btnOK2.prop(\'disabled\',false);cDtmvtolt.habilitaCampo();focaCampoErro(\'dtmvtolt\', \'frmCab\');';

	// Recebe o POST
	$dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : 0  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
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
	$xml .= '		<dtmvtolt>'.$dtmvtolt.'</dtmvtolt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "REAFOR", "CONSFOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$registros 	= $xmlObjeto->roottag->tags;

	include('tab_dados.php');
?>