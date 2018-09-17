<?
/*!
 * FONTE        : gravar_dados.php                               Última alteração: 29/10/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 18/08/2015
 * OBJETIVO     : Rotina para gravar dados
 * --------------
 * ALTERAÇÕES   : 29/10/2015 - Ajustes de homologação refente a conversão realizada pela DB1
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
	$rowid       = (isset($_POST['rowid'])) ? $_POST['rowid'] : ' ';
	$flgtitul    = (isset($_POST['flgtitul'])) ? $_POST['flgtitul'] : ' ';
	$flgobrig    = (isset($_POST['flgobrig'])) ? $_POST['flgobrig'] : ' ';
	$cdrelato    = (isset($_POST['cdrelato'])) ? $_POST['cdrelato'] : 0;
	$cdprogra    = (isset($_POST['cdprogra'])) ? $_POST['cdprogra'] : 0;
	$cddfrenv    = (isset($_POST['cddfrenv'])) ? $_POST['cddfrenv'] : 0;
	$cdperiod    = (isset($_POST['cdperiod'])) ? $_POST['cdperiod'] : 0;
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
				
	// Executa script para envio do XML	
	if($cddopcao == 'I'){
		// Monta o xml de requisição
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
		$xml .= '		<flgtitul>'.$flgtitul.'</flgtitul>';
		$xml .= '		<flgobrig>'.$flgobrig.'</flgobrig>';
		$xml .= '		<cdrelato>'.$cdrelato.'</cdrelato>';
		$xml .= '		<cdprogra>'.$cdprogra.'</cdprogra>';
		$xml .= '		<cddfrenv>'.$cddfrenv.'</cddfrenv>';
		$xml .= '		<cdperiod>'.$cdperiod.'</cdperiod>';		
		$xml .= '	</Dados>';
		$xml .= '</Root>';
				
		$xmlResult = mensageria($xml, "CADINF", "INCLUIINFORMATIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
	}else if($cddopcao == 'A'){
		// Monta o xml de requisição
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
		$xml .= '		<flgtitul>'.$flgtitul.'</flgtitul>';
		$xml .= '		<flgobrig>'.$flgobrig.'</flgobrig>';
		$xml .= '		<nrdrowid>'.$rowid.'</nrdrowid>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		
		$xmlResult = mensageria($xml, "CADINF", "ALTERAINFORMATIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	}else{
		exibirErro('error','Op&ccedil;&atilde;o inv&aacute;lida.'.$cddopcao,'Alerta - Ayllos','$(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();',false);
	}
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$campo    = ucfirst($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']);
		if ($campo != ''){
			$retornoAposErro = 'c'.$campo.'.focus();'.'c'.$campo.'.addClass(\'campoErro\');'."blockBackground(parseInt($('#divRotina').css('z-index')));";
		}else{
			$retornoAposErro = '$(\'#btVoltar\',\'#divBotoesInclui\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
		}
		
		$codErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

?>
