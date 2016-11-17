<? 
/*!
 * FONTE        : manter_rotina_pco.php
 * CRIAÇÃO      : Tiago Machado Flor         
 * DATA CRIAÇÃO : 27/03/2013 
 * OBJETIVO     : Rotina para manter as operações da tela CADPCO
 * --------------
 * ALTERAÇÕES   : 26/06/2014 - Correcao da rotina de replicacao
			      de parametros a partir da inclusao - 151018
				  Carlos Rafael Tanholi
 * -------------- 
 */

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	//contem o nome resumido da cooperativa para a opcao IR
	$nmrescop = '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdpartar		= (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0  ; 
	$tpdedado		= (isset($_POST['tpdedado'])) ? $_POST['tpdedado'] : 0  ; 	
	$cdcopatu		= (isset($_POST['cdcopatu'])) ? $_POST['cdcopatu'] : 0  ; 	
	$dsconteu		= (isset($_POST['dsconteu'])) ? $_POST['dsconteu'] : '' ; 		
	$lstdscon		= (isset($_POST['lstdscon'])) ? $_POST['lstdscon'] : '' ; 	
	$lstcdcop		= (isset($_POST['lstcdcop'])) ? $_POST['lstcdcop'] : '' ; 	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'buscar-cadpco';	 break;
		case 'I': $procedure = 'incluir-cadpco'; break;
		case 'A': $procedure = 'alterar-cadpco'; break;
		case 'E': $procedure = 'excluir-cadpco'; break;
		case 'R': $procedure = 'replicar-cadpco'; break;
		case 'V': $procedure = 'validar-cadpco'; break;
		case 'IR': $procedure = 'incluir-cadpco'; break;
	}
	
	if ($cddopcao == 'IR'){
		$cddopcao = 'I';
		$cddopcaoAnt = 'IR';
	}else if($cddopcao == 'V'){
		$cddopcao = 'C';
		$cddopcaoAnt = 'V';
	}else if($cddopcao == 'R'){
		$cddopcao = 'I';
		$cddopcaoAnt = 'R';
	}
	
	$retornoAposErro = 'focaCampoErro(\'cdcooper\', \'frmParametroCoop\');bloqueiaFundo($(\'#divRotina\'));';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	if ($cddopcao == 'I') { //quando incluir e replicar sera consultado o nome da cooperativa
	
		// Monta o xml dinâmico de acordo com a operação 
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Cabecalho>';
		$xml .= '		<Bo>b1wgen0153.p</Bo>';
		$xml .= '		<Proc>buscar-cooperativa</Proc>';
		$xml .= '	</Cabecalho>';
		$xml .= '	<Dados>';
		$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';		
		$xml .= '       <cdcopatu>'.$cdcopatu.'</cdcopatu>';
		$xml .= '		<flgerlog>YES</flgerlog>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);
		$nmrescop = "'".$xmlObjeto->roottag->tags[0]->attributes["NMRESCOP"]."'";	
		$dsconteu = "'".$dsconteu."'";	
	}
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

		
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0153.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cdpartar>'.$cdpartar.'</cdpartar>';
	$xml .= '		<cdcopatu>'.$cdcopatu.'</cdcopatu>';
	$xml .= '		<dsconteu>'.$dsconteu.'</dsconteu>';	
	$xml .= '		<lstdscon>'.$lstdscon.'</lstdscon>';
	$xml .= '		<lstcdcop>'.$lstcdcop.'</lstcdcop>';	
	$xml .= '		<flgerlog>YES</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$cddopcao = ($cddopcaoAnt != '') ? $cddopcaoAnt : $cddopcao;

	if ($cddopcao == "I" ) {
		echo 'showError("inform","Par&acirc;metro alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaEstadoManterRotinaPco();");';	
	}else if ($cddopcao == "IR"){
		echo 'showError("inform","Par&acirc;metro incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));setaGlobalTab('.$cdcopatu.', '.$dsconteu.', '.$nmrescop.');mostraParametroCoop(\'R\');");';
	}else if ($cddopcao == "A"){
		echo 'showError("inform","Par&acirc;metro alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaEstadoManterRotinaPco();");';
	}else if ($cddopcao == "E"){
		echo 'showError("inform","Par&acirc;metro excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaEstadoManterRotinaPco();");';
	}else if ($cddopcao == "R"){
		echo 'showError("inform","Par&acirc;metro replicado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaEstadoManterRotinaPco();");';
	}else if ($cddopcao == "V" || $cddopcao == "C"){
		echo 'hideMsgAguardo();buscaCooperativa(); $(\'#dsconteu\',\'#frmParametroCoop\').focus();';
	}	
?>