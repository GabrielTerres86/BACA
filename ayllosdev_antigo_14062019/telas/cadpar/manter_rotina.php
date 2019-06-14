<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 07/03/2013 
 * OBJETIVO     : Rotina para manter as operações da tela CADPAR
 * --------------
 * ALTERAÇÕES   : 27/03/2015 - Adicionado parametro dsprodut. (Jorge/Rodrigo - SD 229250)
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
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdpartar		= (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0  ; 
	$cdsubgru		= (isset($_POST['tpdedado'])) ? $_POST['tpdedado'] : 0  ; 	
	$nmpartar		= (isset($_POST['nmpartar'])) ? $_POST['nmpartar'] : ''  ; 	
	$tpdedado       = (isset($_POST['tpdedado'])) ? $_POST['tpdedado'] : ''  ;
	$cdprodut       = (isset($_POST['cdprodut'])) ? $_POST['cdprodut'] : 0  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'buscar-cadpar';	 break;
		case 'I': $procedure = 'incluir-cadpar'; break;
		case 'A': $procedure = 'alterar-cadpar'; break;
		case 'E': $procedure = 'excluir-cadpar'; break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cdpartar\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
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
	$xml .= '		<tpdedado>'.$tpdedado.'</tpdedado>';
	$xml .= '		<nmpartar>'.$nmpartar.'</nmpartar>';
	$xml .= '		<cdprodut>'.$cdprodut.'</cdprodut>';
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
	
	$tpdedado = $xmlObjeto->roottag->tags[0]->attributes["TPDEDADO"];
	$nmpartar = $xmlObjeto->roottag->tags[0]->attributes["NMPARTAR"];
	
	
	if ($cddopcao == "C"){
		echo "$('#tpdedado','#frmCab').val('$tpdedado');";
		echo "$('#nmpartar','#frmCab').val('$nmpartar');";
		echo "$('#tpdedado','#frmCab').desabilitaCampo();";
		echo "$('#nmpartar','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').focus();";
		echo "trocaBotao('');";
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","Par&acirc;metro incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaEstadoManterRorina();");';		
		
	}
	
	if ($cddopcao == "A"){
		echo 'showError("inform","Par&acirc;metro alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaEstadoManterRorina();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","Par&acirc;metro excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	

			
?>
