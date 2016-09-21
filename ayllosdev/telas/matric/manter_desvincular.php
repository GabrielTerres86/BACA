<? 
/*!
 * FONTE        : manter_desvincular.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/06/2010 
 * OBJETIVO     : Rotina para [ D ] desvincular uma conta da tela MATRIC
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	$rowidass = (isset($_POST['rowidass'])) ? $_POST['rowidass'] : '' ;
	$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : '' ;
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '' ;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;
		
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) {
		case 'DV': $procedure = 'valida_dados'; $cddopcao = 'D'; break;
		case 'VD': $procedure = 'grava_dados' ; $cddopcao = 'D'; break;
		default: return false;
	}
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0052.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';    	
	$xml .= '       <idseqttl>1</idseqttl>';    	
	$xml .= '       <rowidass>'.$rowidass.'</rowidass>';    	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';  
	$xml .= '       <nmprimtl>'.$nmprimtl.'</nmprimtl>';  
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';  
	$xml .= '       <inpessoa>'.$inpessoa.'</inpessoa>';  
	$xml .= '       <cdagepac>'.$cdagepac.'</cdagepac>';  
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';                                      
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	

	// Include do arquivo que analisa o resultado do XML
	include('./manter_resultado.php');	
?>