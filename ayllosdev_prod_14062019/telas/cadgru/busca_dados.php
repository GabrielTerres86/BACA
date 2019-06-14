<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 26/02/2013 
 * OBJETIVO     : Rotina para buscar grupo na tela CADGRU
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
	$cddgrupo		= (isset($_POST['cddgrupo'])) ? $_POST['cddgrupo'] : 0  ; 
	$dsdgrupo		= (isset($_POST['dsdgrupo'])) ? $_POST['dsdgrupo'] : 0  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'buscar-cadgru';
	
	$retornoAposErro = 'focaCampoErro(\'cddgrupo\', \'frmCab\');';
	
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
	$xml .= '		<cddgrupo>'.$cddgrupo.'</cddgrupo>';
	$xml .= '		<dsdgrupo>'.$dsdgrupo.'</dsdgrupo>';
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
	
	$dsdgrupo = $xmlObjeto->roottag->tags[0]->attributes["DSDGRUPO"];
	
	echo "$('#dsdgrupo','#frmCab').val('$dsdgrupo');";
	echo "$('#dsdgrupo','#frmCab').habilitaCampo();";
	echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
	echo "$('#dsdgrupo','#frmCab').focus();";
	
	echo "trocaBotao('');";
		
	if ($cddopcao == "A"){
		echo "trocaBotao('Alterar');";
	}
	
	if ($cddopcao == "E"){
		echo "$('#dsdgrupo','#frmCab').desabilitaCampo();";
		echo "trocaBotao('Excluir');";
	}
			
?>
