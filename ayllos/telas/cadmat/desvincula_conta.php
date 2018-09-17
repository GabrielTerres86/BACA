<? 
/*!
 * FONTE        : valida_desvincula_conta.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 09/10/2017
 * OBJETIVO     : Rotina para validar desvinculação de conta (Opção D)
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
	$rowidass = (isset($_POST['rowidass'])) ? $_POST['rowidass'] : '' ;
	$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '' ;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;

	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0052.p</Bo>';
	$xml .= '		<Proc>grava_dados</Proc>';
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
	$xml .= '       <cddopcao>D</cddopcao>';  
	$xml .= '       <nmprimtl>'.$nmprimtl.'</nmprimtl>';  
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';  
	$xml .= '       <inpessoa>'.$inpessoa.'</inpessoa>';  
	$xml .= '       <cdagepac>'.$glbvars['cdpactra'].'</cdagepac>';  
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';                                      
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	

	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Cadmat','estadoInicial();',false);
	} 
	
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle de alertas e retornos
	//----------------------------------------------------------------------------------------------------------------------------------
	$msg 		= Array();
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';	
	$msgAlertas = ( isset($xmlObjeto->roottag->tags[1]->tags) ) ? $xmlObjeto->roottag->tags[1]->tags : array();	
	
	$msgAlertArray = Array();
	foreach( $msgAlertas as $alerta){
		$msgAlertArray[getByTagName($alerta->tags,'cdalerta')] = getByTagName($alerta->tags,'dsalerta');
	}
	
	$msgAlerta = implode( "|", $msgAlertArray);	
		
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	$metodo = "consultaPosDesvinculacao();";			
	$metodoMsg = "exibirMensagens('" . $stringArrayMsg . "','" . $metodo . "')";		
	echo $metodoMsg;
?>