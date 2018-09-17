<? 
/*!
 * FONTE        	: busca_cheque.php
 * CRIAÇÃO      	: Gabriel Capoia (DB1)
 * DATA CRIAÇÃO 	: 11/01/2013
 * OBJETIVO     	: Rotina para buscar cheques - PESQDP
 * ULTIMA ALTERAÇÃO : 02/07/2013
 * --------------
 * ALTERAÇÕES   	: 02/07/2013 - Alterado tipo da variavel aux. (Reinert)					  
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
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$operacao	= (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$cdagenca	= (isset($_POST['cdagenca'])) ? $_POST['cdagenca'] : 0  ;
	$dtmvtola	= (isset($_POST['dtmvtola'])) ? $_POST['dtmvtola'] : '?' ;	
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	
	$cddopcao	= ($cddopcao == 'null') ? '' : $cddopcao ;
	$operacao	= ($operacao == 'null') ? '' : $operacao ;
	
	$retornoAposErro = 'estadoInicial();';	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0152.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <operacao>'.$operacao.'</operacao>';
	$xml .= '       <cdagenca>'.$cdagenca.'</cdagenca>';
	$xml .= '       <dtmvtola>'.$dtmvtola.'</dtmvtola>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';	
	$xml .= '       <dtmvtoan>'.$glbvars['dtmvtoan'].'</dtmvtoan>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
		
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		if (!empty($nmdcampo)) { $mtdErro = " $('#".$nmdcampo."','#frmCab').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	} 
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$justificativas = $xmlObjeto->roottag->tags[1]->tags;
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"]; 				
	
	include ('tab_creditos.php');
	include ('form_creditos.php');
	
		foreach ( $justificativas as $j ) {
			// getByTagName($j->tags,'cddjusti'); 
			// getByTagName($j->tags,'dsdjusti');			
			?><script>
				var aux;
				aux = "<? echo getByTagName($j->tags,'dsdjusti')?>";				
				arrayJust['<? echo getByTagName($j->tags,'cddjusti') ?>'] = aux;
			</script><?
		}	
	
	
?>
