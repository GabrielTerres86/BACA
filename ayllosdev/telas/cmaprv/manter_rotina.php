<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 10/10/2011 
 * OBJETIVO     : Rotina para manter as operações da tela CMAPRV
 * --------------
 * ALTERAÇÕES   : 27/11/2014 - Adicionado replace do caracter "'" em campo dsobscmt (Jorge/Rosangela) - SD 218402
 *                28/05/2015 - Ajustado a solicitação para incluir observação do comitê. (Douglas - Melhoria 18)
 *				  02/10/2015 - Alterado tratamento de mensagem de retorno da verificação de motivo para permitir alterar Observação (Lucas Lunelli SD 323711)
 *			 	  15/10/2015 - Tratamento para mostrar opções de edição de OBS em caso de erro na operacao GD (Lucas Lunelli SD 323711)
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
	
	// formulario
	$operacao		= (isset($_POST['operacao']))   ? $_POST['operacao']   : 0   ; 
	$cddopcao		= (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : ''  ; 
	$dtpropos		= (isset($_POST['dtpropos']))   ? $_POST['dtpropos']   : ''  ; 
	$dtaprova		= (isset($_POST['dtaprova']))   ? $_POST['dtaprova']   : ''  ; 
	$dtaprfim		= (isset($_POST['dtaprfim']))   ? $_POST['dtaprfim']   : ''  ; 
	$aprovad1		= (isset($_POST['aprovad1']))   ? $_POST['aprovad1']   : ''  ; 
	$aprovad2		= (isset($_POST['aprovad2']))   ? $_POST['aprovad2']   : ''  ; 
	
	// dados
	$nrdcont1		= (isset($_POST['nrdcont1']))   ? $_POST['nrdcont1']   : 0  ; 
	$nrctremp		= (isset($_POST['nrctremp']))   ? $_POST['nrctremp']   : 0  ; 
	$insitapv		= (isset($_POST['insitapv']))   ? $_POST['insitapv']   : 0  ;
	$insitaux		= (isset($_POST['insitaux']))   ? $_POST['insitaux']   : 0  ;
	$nrctrliq		= (isset($_POST['nrctrliq']))   ? $_POST['nrctrliq']   : '' ; 
	$vlemprst		= (isset($_POST['vlemprst']))   ? $_POST['vlemprst']   : 0  ; 
	
	// motivo
	$dsobstel		= (isset($_POST['dsobstel']))   ? retiraAcentos(utf8_decode($_POST['dsobstel'])) : '' ;
	$dscmaprv		= (isset($_POST['dscmaprv']))   ? $_POST['dscmaprv']   : '' ;
	$flgalter		= (isset($_POST['flgalter']))   ? $_POST['flgalter']   : '' ;
	
	$dsapraux		= (isset($_POST['dsapraux']))   ? $_POST['dsapraux']   : '' ; 

	// Dependendo da operação, chamo uma procedure diferente
	switch($operacao) {
		case 'VD':  $procedure = 'Valida_Dados';							break;
		case 'VR':  $procedure = 'Verifica_Rating'; 						break;
		case 'VM':  $procedure = 'Verifica_Motivo'; 						break;
		case 'GD':  $procedure = 'Grava_Dados'; 							break;
		default:    $retornoAposErro   = 'estadoInicial();'; return false;	break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0114.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '       <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	// cabecalho
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<dtpropos>'.$dtpropos.'</dtpropos>';
	$xml .= '		<dtaprova>'.$dtaprova.'</dtaprova>';
	$xml .= '		<dtaprfim>'.$dtaprfim.'</dtaprfim>';
	$xml .= '		<aprovad1>'.$aprovad1.'</aprovad1>';
	$xml .= '		<aprovad2>'.$aprovad2.'</aprovad2>';
	// dados 
	$xml .= '		<nrdcont1>'.$nrdcont1.'</nrdcont1>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<insitapv>'.$insitapv.'</insitapv>';
	$xml .= '		<insitaux>'.$insitaux.'</insitaux>';
	$xml .= '		<nrctrliq>'.$nrctrliq.'</nrctrliq>';
	$xml .= '		<vlemprst>'.$vlemprst.'</vlemprst>';
	// motivo
	$xml .= '		<dsobstel>'.$dsobstel.'</dsobstel>';
	$xml .= '		<dscmaprv>'.$dscmaprv.'</dscmaprv>';
	$xml .= '		<flgalter>'.$flgalter.'</flgalter>';
	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."').focus();"; }
		
		if ( $operacao == 'GD' ) { $retornoAposErro = $retornoAposErro . " mostraOpcoes();"; }
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	if ( $operacao == 'VD' ) {
		echo "manterRotina('VR');";
		
	} else if ( $operacao == 'VR' ) {
		$msgalert = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
		$msgretor = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];
		
		if (!empty($msgalert)) {
			exibirErro('inform',$msgalert,'Alerta - Ayllos','manterRotina(\'VM\');',false);
		} else if (!empty($msgretor)) {
			exibirConfirmacao($msgretor,'Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'VM\');','',false);
		} else {
			echo 'manterRotina(\'VM\');';
		}

	} else if ($operacao == 'VM') {
		$cdcomite = $xmlObjeto->roottag->tags[0]->attributes['CDCOMITE'];
		$dsobscmt = $xmlObjeto->roottag->tags[0]->attributes['DSOBSCMT'];
		$flgcmtlc = $xmlObjeto->roottag->tags[0]->attributes['FLGCMTLC'];
		$msgretor = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];
		
		if (!empty($msgretor)) {
			// exibirErro('inform',$msgretor,'Alerta - Ayllos','manterRotina(\'CO\');',false);
			exibirErro('inform',$msgretor,'Alerta - Ayllos','solicitaIncluirObservacao(true);',false);
		} else {
			if ( $dsobscmt != "" and (($flgcmtlc == 'yes' and $cdcomite == 2) or $flgcmtlc == 'no') ) {
				echo "solicitaIncluirObservacao(true);";
			} else {
				echo "solicitaIncluirObservacao(false);";
			}			
		}
		
	} else if ( $operacao == 'GD' ) {
		$registro 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		$cdopeapv 	= getByTagName($registro,'cdopeapv')."-".stringTabela(getByTagName($registro,'nmoperad'),18,'maiuscula');

		if ( $insitapv != $insitaux) {
			// tabela
			echo "$('#cdopeap1',seletor).val('".$cdopeapv."');";
			echo "$('#dtaprov1',seletor).val('".getByTagName($registro,'dtaprova')."');";
			echo "$('#hrtransa',seletor).val('".getByTagName($registro,'hrtransf')."');";
			echo "$('#insitapv',seletor).val('".$insitapv."');";
			echo "$('#dsaprova',seletor).val('".$dsapraux."');";
		}

		$dsobscmt = getByTagName($registro,'dsobscmt');

		$dsobscmt = str_replace("\r", "@@", $dsobscmt);
		$dsobscmt = str_replace("\n", "@@", $dsobscmt);
		$dsobscmt = str_replace("\r\n","@@", $dsobscmt);
		$dsobscmt = str_replace("\t", "@@", $dsobscmt);
		$dsobscmt = str_replace("'", "@@", $dsobscmt);		
		
		echo "$('#dsobscmt',seletor).val('".trim($dsobscmt)."');";
		
		echo "selecionaTabela( seletor );";
		echo "hideMsgAguardo();";
	}
	
?>