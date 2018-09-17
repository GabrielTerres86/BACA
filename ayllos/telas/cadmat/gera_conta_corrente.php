<?
/*!
 * FONTE        : consulta_pre_inclusao.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 29/09/2017
 * OBJETIVO     : Busca dados de cadastro de pessoa no CRM
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

	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0052.p</Bo>';
	$xml .= '		<Proc>Retorna_Conta</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';                                      
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}

	$nrctanov = ( isset($xmlObjeto->roottag->tags[0]->attributes['NRCTANOV']) ) ? formataContaDVsimples($xmlObjeto->roottag->tags[0]->attributes['NRCTANOV']) : '';	

	if ($nrctanov == 0 || $nrctanov == '') {
		exibirErro('error','Não foi possivel gerar a nova C/C.','Alerta - Ayllos','',false);
		exit();
	}
		
	echo "$('#nrdconta','#frmCab').val('$nrctanov');";
	echo "$('#nrdconta','#frmCadmat').val('$nrctanov');";
	echo "duplicaContaCorrente('$nrctanov');";
	
?>