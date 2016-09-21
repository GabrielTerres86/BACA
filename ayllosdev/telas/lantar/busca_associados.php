<? 
/*!
 * FONTE        : busca_associados.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 16/04/2013
 * OBJETIVO     : Efetua busca associados via XML
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
	$nmprimtl		= (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ; 
	$cagencia		= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 ; 
	$inpessoa		= (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0 ; 
	$cdtipcta		= (isset($_POST['cdtipcta'])) ? $_POST['cdtipcta'] : 0 ; 
	$flgchcus		= (isset($_POST['flgchcus'])) ? $_POST['flgchcus'] : false ; 
	$mespsqch		= (isset($_POST['mespsqch'])) ? $_POST['mespsqch'] : 0 ; 
	$anopsqch		= (isset($_POST['anopsqch'])) ? $_POST['anopsqch'] : 0 ;
	$nrregist 		= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ; 
	$nriniseq 		= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ; 
	$arrpesqu		= (isset($_POST['arrpesqu'])) ? $_POST['arrpesqu'] : '' ; 
	
	
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'carrega-tabassociado';
	
	$retornoAposErro = 'focaCampoErro(\'nmprimtl\', \'frmPesquisaAssociado\');';
	
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
	$xml .= '		<nmprimtl>'.$nmprimtl.'</nmprimtl>';	
	$xml .= '		<cagencia>'.$cagencia.'</cagencia>';	
	$xml .= '		<inpessoa>'.$inpessoa.'</inpessoa>';	
	$xml .= '		<cdtipcta>'.$cdtipcta.'</cdtipcta>';	
	$xml .= '		<flgchcus>'.$flgchcus.'</flgchcus>';
	$xml .= '		<mespsqch>'.$mespsqch.'</mespsqch>';
	$xml .= '		<anopsqch>'.$anopsqch.'</anopsqch>';	
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';	
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
	
	$associados = $xmlObjeto->roottag->tags[0]->tags; 
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	$conta = 0;
	
	include('tab_associados.php');
	
?>