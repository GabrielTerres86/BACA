<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 26/02/2013
 * OBJETIVO     : Rotina para buscar dados - CTASAL
 * --------------
 * ALTERAÇÕES   : Ajuste para caracteres especiais não gerarem problemas. (SD 845660 - Kelvin).
 * -------------- 
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
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	
	$cddopcao	= ($cddopcao == 'null') ? '' : $cddopcao  ;	
	
	$retornoAposErro = 'estadoInicial();';
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0151.p</Bo>';
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
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML(removeCaracteresInvalidos($xmlResult));
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;		
		$mtdErro = " $('#nrdconta','#frmCab').focus();";
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	} 
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$registro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;	
			
	include ('form_dados.php');
?>