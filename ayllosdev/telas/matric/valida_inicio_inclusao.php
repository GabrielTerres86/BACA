<? 
/*!
 * FONTE        : manter_desvincular.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/06/2010                           Ultima Alteração: 27/04/2012
 
 * OBJETIVO     : Rotina para [ D ] desvincular uma conta da tela MATRIC
 
   Alterações   : 	27/04/2012 - Incluido novo parametro dtmvtolt da b1wgen0052.p
                                 (David Kruger).   
                                                                     
 *****************************************************************************************/
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
	$cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : '' ;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;
		
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0052.p</Bo>';
	$xml .= '		<Proc>Valida_Inicio_Inclusao</Proc>';
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
	$xml .= '       <inpessoa>'.$inpessoa.'</inpessoa>';  
	$xml .= '       <cdagepac>'.$cdagepac.'</cdagepac>';  
    $xml .= '       <dtmvtolt>'.$dtmvtolt.'</dtmvtolt>';  	
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';                                      
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {		
		$mtdErro   = '';
		$msgErro   = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nomeCampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];		
		
		// Limpa o sinalizador de erro em todos os campos 
		echo '$(\'input,select\',\'#frmCabMatric\').removeClass(\'campoErro\');';
		
		// Se existe o atributo nome do campo, então ocorreu erro neste campo, portanto focá-lo, caso contrario somente apresentar o erro		
		if ( $nomeCampo != '' ) {
			$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\'frmCabMatric\')';
		} else {
			$mtdErro = 'unblockBackground()';
		}		
		
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	} else {
		echo 'hideMsgAguardo();';
		echo 'formataInclusao();';
	}

?>