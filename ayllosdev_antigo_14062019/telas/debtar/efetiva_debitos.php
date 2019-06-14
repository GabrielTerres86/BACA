<? 
/*!
 * FONTE        : efetiva_debitos.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 23/02/2015
 * OBJETIVO     : efetivar lancamento de tarifas pendentes
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
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cdcooper		= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0 ;
	$listalat		= (isset($_POST['listalat'])) ? $_POST['listalat'] : '' ;	
	
	$retornoAposErro = 'focaCampoErro(\'cdtarifa\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dsorigem>'.$glbvars['dsorigem'].'</dsorigem>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<listalat>'.$listalat.'</listalat>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "DEBTAR", "DEBTAR_EFETIVAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if(strtoupper($xmlObjeto->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibeErro($msgErro,$frm);
		exit();
	}
	
	$parametros = $xmlObjeto->roottag->tags[0]->tags;
	$nmarqpdf = getByTagName($parametros,'nmarqpdf');
	
	
	echo "trocaBotao('Log');";
	echo "botaoPDF('$nmarqpdf');";

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro,$frm) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error",\''.$msgErro.'\',"Alerta - Aimaro","$(\'#vllanmto\',\''.$frm.'\').focus(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	echo 'showError("inform","Processo concluido com sucesso. Verifique log.","Notifica&ccedil;&atilde;o - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));unblockBackground();");';
	
?>
