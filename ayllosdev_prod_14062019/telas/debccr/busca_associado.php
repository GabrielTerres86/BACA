<? 
/*!
 * FONTE        : busca_associado.php
 * CRIAÇÃO      : Tiago
 * DATA CRIAÇÃO : 20/03/2015
 * OBJETIVO     : Rotina para buscar dados associasdo na tela debtar
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
	$procedure			= 'busca-associado-reltar';
	
	// Recebe a operação que está sendo realizada
	$nrdconta			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$cdagetel			= 0;
	$ccooptel			= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {		
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
	$xml .= '       <ccooptel>'.$ccooptel.'</ccooptel>';
	$xml .= '       <cdagetel>'.$cdagetel.'</cdagetel>';
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
	
	echo "$('#nmprimtl','#frmDebccr').val('$nmprimtl');";
	echo "$('#nrdconta','#frmDebccr').desabilitaCampo();";
		
?>
