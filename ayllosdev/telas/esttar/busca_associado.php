<? 
/*!
 * FONTE        : busca_associado.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 15/03/2013
 * OBJETIVO     : Rotina para buscar dados associasdo na tela ESTTAR
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
	$retornoAposErro	= 'cNrdconta.focus();';
	$procedure			= 'busca-associado';
	
	// Recebe a operação que está sendo realizada
	$nrdconta			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
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
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
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
	
	$cdagenci = $xmlObjeto->roottag->tags[0]->attributes["CDAGENCI"];
	$nmresage = $xmlObjeto->roottag->tags[0]->attributes["NMRESAGE"];
	$nmprimtl = $xmlObjeto->roottag->tags[0]->attributes["NMPRIMTL"];
	
	echo "$('#cdagenci','#frmCab').val('$cdagenci - $nmresage');";
	echo "$('#nmprimtl','#frmCab').val('$nmprimtl');";
	echo "cDtinicio.val('".$glbvars['dtmvtolt']."');";
	echo "cDtafinal.val('".$glbvars['dtmvtolt']."');";
	echo "$('#dtinicio','#frmCab').habilitaCampo();";
	echo "$('#dtinicio','#frmCab').focus();";
		
?>
