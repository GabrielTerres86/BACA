<? 
/*!
 * FONTE        : busca_dados_parametro.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 07/03/2013 
 * OBJETIVO     : Rotina para buscar dados categoria tela CADPAR
 * --------------
 * ALTERAÇÕES   : 06/05/2015 - Adicionado campo CDPRODUT e DSPRODUT no retorno da base. (Jorge/Rodrigo - SD 229250)
 * 
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
	$procedure 		= 'buscar-cadpar';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdpartar		= (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0  ;  

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'buscar-cadpar';
	
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
	
	$nmpartar = $xmlObjeto->roottag->tags[0]->attributes["NMPARTAR"];
	$tpdedado = $xmlObjeto->roottag->tags[0]->attributes["TPDEDADO"];
	$cdprodut = $xmlObjeto->roottag->tags[0]->attributes["CDPRODUT"];
	$dsprodut = $xmlObjeto->roottag->tags[0]->attributes["DSPRODUT"];
	
	echo "$('#nmpartar','#frmCab').val('$nmpartar');";
	echo "$('#tpdedado','#frmCab').val('$tpdedado');";
	echo "$('#cdprodut','#frmCab').val('$cdprodut');";
	echo "$('#dsprodut','#frmCab').val('$dsprodut');";
	echo "$('#cdpartar','#frmCab').desabilitaCampo();";
	
	echo "$('#divBotoesTabCadpar').show();";
	
	if ($cddopcao == "E"){
		echo "$('#nmpartar','#frmCab').desabilitaCampo();";		
		echo "$('#tpdedado','#frmCab').desabilitaCampo();";	
		echo "trocaBotao('Excluir');";
	}
	
	if ($cddopcao == "A"){
		echo "$('#nmpartar','#frmCab').habilitaCampo();";
		echo "trocaBotao('Alterar');";
	}
	
	if ($cddopcao == "C"){
		echo "controlaEstadoManterRorina();";
		echo "$('#divBotoesTabCadpar').hide();";
	}
	
	echo "$('#nmpartar','#frmCab').focus();";
			
?>
