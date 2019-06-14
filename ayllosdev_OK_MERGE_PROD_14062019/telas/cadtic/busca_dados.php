<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Daniel Zimmermann / Tiago Machado Flor      
 * DATA CRIAÇÃO : 28/02/2013 
 * OBJETIVO     : Rotina para buscar grupo na tela CADTIC
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
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdtipcat		= (isset($_POST['cdtipcat'])) ? $_POST['cdtipcat'] : 0  ; 
	$dstipcat		= (isset($_POST['dstipcat'])) ? $_POST['dstipcat'] : 0  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'buscar-cadtic';
	
	$retornoAposErro = 'focaCampoErro(\'cdtipcat\', \'frmCab\');';
	
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
	$xml .= '		<cdtipcat>'.$cdtipcat.'</cdtipcat>';
	$xml .= '		<dstipcat>'.$dstipcat.'</dstipcat>';
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
	
	$dstipcat = $xmlObjeto->roottag->tags[0]->attributes["DSTIPCAT"];
	
	echo "$('#dstipcat','#frmCab').val('$dstipcat');";
	echo "$('#dstipcat','#frmCab').habilitaCampo();";
	echo "$('#cdtipcat','#frmCab').desabilitaCampo();";
	echo "$('#dstipcat','#frmCab').focus();";
	
	echo "trocaBotao('');";
		
	if ($cddopcao == "A"){
		echo "trocaBotao('Alterar');";
	}
	
	if ($cddopcao == "E"){
		echo "$('#dstipcat','#frmCab').desabilitaCampo();";
		echo "trocaBotao('Excluir');";
	}
			
?>
