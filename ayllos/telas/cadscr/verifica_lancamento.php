<?
/*!
 * FONTE        : verifica_lancamento.php						Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 09/10/2015
 * OBJETIVO     : Rotina para verificar os dados dos lancamentos scr da tela CADSCR
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

	$retornoAposErro = '';
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';	
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : '';
	$dtsolici = (isset($_POST["dtsolici"])) ? $_POST["dtsolici"] : '';
	$dtrefere = (isset($_POST["dtrefere"])) ? $_POST["dtrefere"] : '';
	$cdhistor = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	if($cddopcao == 'B' or $cddopcao == 'L'){

		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<dtsolici>".$dtsolici."</dtsolici>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<dtrefere>".$dtrefere."</dtrefere>";		
		$xml .= "		<cdhistor>".$cdhistor."</cdhistor>";
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "		<flgvalid>1</flgvalid>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
	}else{
		
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<dtsolici>".$dtsolici."</dtsolici>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<dtrefere>".$dtrefere."</dtrefere>";
		$xml .= "		<cdhistor>".$cdhistor."</cdhistor>";
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "		<flgvalid>0</flgvalid>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
	}
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADSCR", "VERIFICALANCAMENTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if($cddopcao == 'L'){
			$retornoAposErro .= '$(\'input\',\'#frmConsulta\').habilitaCampo();$(\'#dtsolici\',\'#frmConsulta\').addClass(\'campoErro\').focus(); $(\'#frmConsulta\').css(\'display\',\'block\'); $(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();';
		}else{
			$retornoAposErro .= '$(\'#dtsolici\',\'#frmConsulta\').addClass(\'campoErro\').habilitaCampo().focus(); $(\'#frmConsulta\').css(\'display\',\'block\');';
		}
			
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		
	}	
	
	if($cddopcao == "X"){ 
		
		echo "blockBackground(parseInt($('#divRotina').css('z-index')) );";
		echo 'showConfirmacao("Pe&ccedil;a a libera&ccedil;&atilde;o ao Coordenador/Gerente...","Confirma&ccedil;&atilde;o - Ayllos","$(\'#frmConsulta\').css(\'display\',\'none\'); $(\'#frmSenha\').css(\'display\',\'block\'); $(\'#btSalvar\',\'#divBotoes\').hide(); $(\'#btSalvarSenha\',\'#divBotoes\').show(); cOperador.focus();","$(\'#dtsolici\',\'#frmConsulta\').habilitaCampo().focus(); $(\'#frmConsulta\').css(\'display\',\'block\'); $(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();","continuar.gif","cancelar.gif");';
		
	}

?>