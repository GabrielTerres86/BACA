<?
/*!
 * FONTE        : excluir_informativo.php                �ltima altera��o: 29/10/2015 
 * CRIA��O      : J�ssica - DB1
 * DATA CRIA��O : 18/08/2015
 * OBJETIVO     : Rotina para excluir informativos da tela CADINF
 * --------------
 * ALTERA��ES   : 29/10/2015 - Ajustes de homologa��o refente a convers�o realizada pela DB1
							   (Adriano).
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
	$rowid       = (isset($_POST['rowid'])) ? $_POST['rowid'] : ' '  ;
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
	$xml .= '		<rowid>'.$rowid.'</rowid>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADINF", "EXCLUIINFORMATIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$retornoAposErro = "";	
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

?>