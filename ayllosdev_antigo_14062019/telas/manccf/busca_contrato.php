<? 
/*!
 * FONTE        : busca_contrato.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Rotina para buscar dados da tela MANCCF
 * --------------
 * ALTERAÇÕES   : 01/07/2015 - Alterado na chamada da funcao validaPermissao onde estava passando
							   o parametro "C" para "I" pois  não estava validando corretamente
							   as permissoes conforme relata o chamado 302218. (KevliN) 
 * 						 
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
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	
//	$retornoAposErro = 'estadoInicial(); $(#nrdconta,#frmCab).focus();';
	$retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmCab\');';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}	


	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0143.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';		
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		
		if (!empty($nmdcampo)) { $mtdErro = " $('#".$nmdcampo."','#frmCab').focus();"; }
		
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);		
	} 
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
		
	include ('tab_contrato.php');
	
	$nmprimtl  = $xmlObjeto->roottag->tags[0]->attributes['NMPRIMTL'];	
	
?>
<script type="text/javascript">

	cNmprimtl.val("<? echo $nmprimtl; ?>");
    
	formataTabela();	
</script>