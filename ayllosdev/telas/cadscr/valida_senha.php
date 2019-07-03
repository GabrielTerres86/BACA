<?
/*!
 * FONTE        : valida_senha.php							Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 18/10/2015
 * OBJETIVO     : Rotina para validar senha da opção X da tela CADSCR
 * --------------
 * ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1
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
	$operador = (isset($_POST["operador"])) ? $_POST["operador"] : '';
	$nrdsenha = (isset($_POST["nrdsenha"])) ? $_POST["nrdsenha"] : '';
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	$nrdsenha = mb_convert_encoding(urldecode($nrdsenha), "Windows-1252", "UTF-8");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <nvoperad>2</nvoperad>';
	$xml .= '		<operador>'.$operador.'</operador>';	
	$xml .= '		<nrdsenha><![CDATA['.$nrdsenha.']]></nrdsenha>';
	$xml .= '		<flgerlog>1</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADSCR", "VALIDASENHACOORD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#divSenha\').removeClass(\'campoErro\'); $(\'input\',\'#divSenha\').habilitaCampo(); focaCampoErro(\'operador\',\'divSenha\');',false);				
		
	}

	echo "atualizaArquivo();";
	
?>