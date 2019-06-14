<? 
/*!
 * FONTE        : gera_log.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 12/07/2011 
 * OBJETIVO     : Rotina para gerar log
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
	$mtdErro	= 'estadoCabecalho();';
	$cddopcao 	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; // ContraOrdens
	$camposDc 	= (isset($_POST['camposDc'])) ? $_POST['camposDc'] : '' ; // ContraOrdens
	$dadosDc 	= (isset($_POST['dadosDc']))  ? $_POST['dadosDc']  : '' ; // ContraOrdens

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0095.p</Bo>';
	$xml .= '		<Proc>gera-log</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<idseqttl>1</idseqttl>';
	$xml .= 		retornaXmlFilhos( $camposDc, $dadosDc, 'ContraOrdens', 'Registro');
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	$msgretor 	= $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	}	

	echo "btnVoltar();";
	
?>