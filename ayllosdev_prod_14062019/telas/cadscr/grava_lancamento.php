<?
/*!
 * FONTE        : grava_lancamento.php					Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 18/10/2015
 * OBJETIVO     : Rotina para gravar dados
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
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$dtsolici = (isset($_POST['dtsolici'])) ? $_POST['dtsolici'] : '';
	$dtrefere = (isset($_POST['dtrefere'])) ? $_POST['dtrefere'] : '';
	$cdhistor = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : 0;
	$vllanmto = (isset($_POST["vllanmto"])) ? $_POST["vllanmto"] : '';
	$vllanmto = str_replace(',','.',str_replace('.','',$vllanmto));

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	validaDados();	
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dtsolici>'.$dtsolici.'</dtsolici>';
	$xml .= '		<dtrefere>'.$dtrefere.'</dtrefere>';
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '		<vllanmto>'.$vllanmto.'</vllanmto>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<operacao>'.$operacao.'</operacao>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADSCR", "GRAVALANCAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$campo    = ucfirst($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']);
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
					
		if($operacao != 'E'){
			exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#vllanmto\',\'frmDados\').addClass(\'campoErro\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
		}else{
			exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#vllanmto\',\'frmDados\').addClass(\'campoErro\').focus();',false);
		}
	}

	function validaDados(){
			
		//Conta
		if ( $GLOBALS["nrdconta"] == 0){ 
		 	exibirErro('error','Conta inv&aacute;lida!','Alerta - Ayllos','focaCampoErro(\'vllanmto\',\'frmDados\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}	
		
		//Valor
		if ( $GLOBALS["vllanmto"] == ''){ 
		 	exibirErro('error','Valor n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'vllanmto\',\'frmDados\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}	
		
		//Histórico
		if ( $GLOBALS["cdhistor"] == 0){ 
		 	exibirErro('error','Hist&oacute;rico n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'vllanmto\',\'frmDados\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}	
		
		//Data de solicitação
		if ( $GLOBALS["dtsolici"] == ''){ 
		 	exibirErro('error','Data de solicita&ccedil;&atilde;o inv&aacute;lida!','Alerta - Ayllos','focaCampoErro(\'vllanmto\',\'frmDados\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}	
		
		//Data de referência
		if ( $GLOBALS["dtrefere"] == ''){ 
		 	exibirErro('error','Data de refer&ecirc;ncia inv&aacute;lida!','Alerta - Ayllos','focaCampoErro(\'vllanmto\',\'frmDados\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}	
		
	}
	
?>