<? 
/*!
 * FONTE        : atualiza_inassele.php
 * CRIAÇÃO      : Lucas Ranghetti (CECRED)
 * DATA CRIAÇÃO : 18/04/2016
 * OBJETIVO     : Rotina para manter, atualizar o campo inassele da tabela crapatr
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

	// Varivel de controle do caracter
	$cdrefere 	= (isset($_POST['cdrefere'])) ? $_POST['cdrefere'] : ''  ;
	$cdhistor 	= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0  ;
	$inassele   = (isset($_POST['inassele'])) ? $_POST['inassele'] : 1  ;
	$nrdconta 	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0092.p</Bo>';
	$xml .= '		<Proc>atualiza_inassele</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<flgerlog>yes</flgerlog>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<inassele>'.$inassele.'</inassele>';
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '		<cdrefere>'.$cdrefere.'</cdrefere>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$mtdErro = '';
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	}else{
		echo "fechaRotina($('#divRotina'));";
		echo "hideMsgAguardo();";
	}
	
?>