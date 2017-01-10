<? 
/*!
 * FONTE        : altera_agencia.php
 * CRIA��O      : David Kruger        
 * DATA CRIA��O : 13/02/2013
 * OBJETIVO     : Rotina para altera��o, exclus�o e inclus�o cadastral da tela AGENCI
 * --------------
 * ALTERA��ES   : 08/01/2014 - Ajustes para homologa��o (Adriano).
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
	$procedure 	= '';
		
	// Recebe a opera��o que est� sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdageban		= (isset($_POST['cdageban'])) ? $_POST['cdageban'] : 0  ; 	
	$cddbanco		= (isset($_POST['cddbanco'])) ? $_POST['cddbanco'] : 0  ; 	
	$dgagenci       = (isset($_POST['dgagenci'])) ? $_POST['dgagenci'] : 0  ;
	$nmageban       = (isset($_POST['nmageban'])) ? $_POST['nmageban'] :''  ;
	$cdsitagb       = (isset($_POST['cdsitagb'])) ? $_POST['cdsitagb'] : 0  ;
	
	
	if($cddopcao != 'E'){ 
	    validaDados();
	}
	
	switch($cddopcao) {
		case 'A': $procedure = 'altera-agencia'; break;
		case 'I': $procedure = 'nova-agencia';   break;
		case 'E': $procedure = 'deleta-agencia'; break;
		
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	
	// Monta o xml din�mico de acordo com a opera��o 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0149.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<cdageban>'.$cdageban.'</cdageban>';	
	$xml .= '		<cddbanco>'.$cddbanco.'</cddbanco>';	
	$xml .= '		<dgagenci>'.$dgagenci.'</dgagenci>';
    $xml .= '		<nmageban>'.$nmageban.'</nmageban>';
	$xml .= '		<cdsitagb>'.$cdsitagb.'</cdsitagb>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmAgencia').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmAgencia');";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
		
	}
		
	echo "hideMsgAguardo();";
	echo "estadoInicial();";
	
	function validaDados() {
	
		// N�mero da agencia.
		if ( (!validaInteiro($GLOBALS['cdageban'])) || ($GLOBALS['cdageban'] == '' ) || ($GLOBALS['cdageban'] == 0 )) exibirErro('error','Agencia inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'cdageban\',\'frmAgencia\');',false);
		
		//Campo nome da agencia.
		if ($GLOBALS['nmageban'] == '') exibirErro('error','Nome inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'nmageban\',\'frmAgencia\');',false);
		
					
	}
	
	
?>
