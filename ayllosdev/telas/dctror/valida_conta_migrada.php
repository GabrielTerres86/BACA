<? 
/*!
 * FONTE        : valida_conta_migrada.php
 * CRIAÇÃO      : Lucas Ranghetti
 * DATA CRIAÇÃO : 02/06/2016
 * OBJETIVO     : Rotina para validar se é conta migrada
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
	$mtdErro	= '';
	$mtdRetorno	= '';
	
	$nrdconta 	= (isset($_POST['nrdconta']))  ? $_POST['nrdconta']  : '' ; 
	$idseqttl	= 1;
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0095.p</Bo>';
	$xml .= '		<Proc>valida-conta-migrada</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $mtdErro = $mtdErro . "$('#".$nmdcampo."','#frmDctror').focus();";  }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	}	
	
	$altagchq	= $xmlObjeto->roottag->tags[0]->attributes['ALTAGCHQ'];
	
	echo "aux_altagchq = '".$altagchq."';";
	
	?>