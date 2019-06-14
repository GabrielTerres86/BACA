<? 
/*!
 * FONTE        : busca_dados_parametro.php
 * CRIAÇÃO      : Tiago Machado        
 * DATA CRIAÇÃO : 19/04/2013
 * OBJETIVO     : Rotina para buscar dados da tarifa na tela CADTAR
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
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$cddopcao       = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;	
	$cdpartar		= (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0  ;	
	$procedure      = 'buscar-cadpar';
	
	$retornoAposErro = 'focaCampoErro(\'cdpartar\', \'frmDadosParametro\');';
	
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
	
	
	echo "$('#nmpartar','#frmDadosParametro').val('$nmpartar');";
	echo "$('#tpdedado','#frmDadosParametro').val('$tpdedado');";

	echo "$('#nmpartar','#frmDadosParametro').desabilitaCampo();";
	echo "$('#tpdedado','#frmDadosParametro').desabilitaCampo();";		

	
	if($cddopcao == "V"){
		echo "$('#cdpartar','#frmDadosParametro').habilitaCampo();";
			
		echo "$('#cdpartar','#frmDadosParametro').focus();";	
	}
	
	if($cddopcao == "C"){
		echo "$('#cdpartar','#frmDadosParametro').desabilitaCampo();";
	}	
	
?>
