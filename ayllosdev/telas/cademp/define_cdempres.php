<? 
/*!
 * FONTE        : define_cdempres.php
 * CRIAÇÃO      : Cristian Filipe       
 * DATA CRIAÇÃO :  
 * OBJETIVO     : Rotina para fazer a busca da tabela de empresas
 * --------------
 * ALTERAÇÕES   : Ajustes conforme SD 122814
 * -------------- 
 */	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = $_POST['cddopcao'];
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '  <Cabecalho>';
	$xml .= '	    <Bo>b1wgen0166.p</Bo>';
	$xml .= "        <Proc>Define_cdempres</Proc>";
	$xml .= '  </Cabecalho>';
	$xml .= '  <Dados>';
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
	$xml .= '  </Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	$cdempres  = $xmlObjeto->roottag->tags[0]->attributes['CDEMPRES'];
	

	echo "$('#cdempres', '#frmInfEmpresa').val('{$cdempres}');";
			
?>
