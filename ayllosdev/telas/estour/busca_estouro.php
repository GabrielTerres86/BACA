<? 
/*!
 * FONTE        : busca_estouro.php
 * CRIAÇÃO      : Jéssica (DB1)					Última alteração: 02/09/2015
 * DATA CRIAÇÃO : 30/07/2013
 * OBJETIVO     : Rotina para buscar estouros - ESTOUR
 * --------------
 * ALTERAÇÕES   : 02/09/2015 - Ajuste para correção da conversão realizada pela DB1
					     	   (Adriano).
 
				  21/07/2017 - Alterações referentes ao cancelamento manual de produtos do projeto 364.(Reinert) 
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
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;	
			
	$retornoAposErro = 'estadoInicial();';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos',$retornoAposErro,false);
	}
	

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0163.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "       <nrregist>".$nrregist."</nrregist>";
	$xml .= "       <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= '	</Dados>';
	$xml .= '</Root>';
			
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		
		if (!empty($nmdcampo)) { $retornoAposErro .= " $('#".$nmdcampo."','#frmCab').addClass(\'campoErro\').focus();btnVoltar();"; }
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);		
		
	} 

	$registros  = $xmlObjeto->roottag->tags[0]->tags;
	$msgauxil	= $xmlObjeto->roottag->tags[0]->attributes['MSGAUXIL'];	
	$nmprimtl	= $xmlObjeto->roottag->tags[0]->attributes['NMPRIMTL'];	
	$qtddtdev	= $xmlObjeto->roottag->tags[0]->attributes['QTDDTDEV'];	
	$qtregist   = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
		
	if ( $msgauxil != "" ){
		exibirErro('inform',$msgauxil,'Alerta - Ayllos',"",true);
	}			
		
	include ('tab_estouro.php');
	
	
?>
<script>	
	$('#nmprimtl','#frmCab').val("<? echo $nmprimtl ?>");
	$('#qtddtdev','#frmCab').val("<? echo $qtddtdev ?>");
	
</script>