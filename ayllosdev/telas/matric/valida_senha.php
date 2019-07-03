<? 
/*!
 * FONTE        : valida_senha.php
 * CRIAÇÃO      : Douglas Quisinski (CECRED)
 * DATA CRIAÇÃO : 09/05/2014
 * OBJETIVO     : Rotina para manter validar senha do operador
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
	$cddopcao 	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$operauto	= (isset($_POST['operauto'])) ? $_POST['operauto'] : '' ;
	$codsenha 	= (isset($_POST['codsenha'])) ? $_POST['codsenha'] : '' ;
	
	$codsenha = mb_convert_encoding(urldecode($codsenha), "Windows-1252", "UTF-8");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	/*
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0000.p</Bo>';
	$xml .= '		<Proc>valida-senha-coordenador</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>0</nrdconta>';
	$xml .= '		<idseqttl>0</idseqttl>';
	$xml .= '		<nvopelib>2</nvopelib>';
	$xml .= '		<cdopelib>'.$operauto.'</cdopelib>';
	$xml .= '		<cddsenha>'.$codsenha.'</cddsenha>';
	$xml .= '		<flgerlog>no</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	*/
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <nrdconta>0</nrdconta>';
	$xml .= '       <idseqttl>0</idseqttl>';
	$xml .= '       <nvoperad>2</nvoperad>';
	$xml .= '		<operador>'.$operauto.'</operador>';	
	$xml .= '		<nrdsenha><![CDATA['.$codsenha.']]></nrdsenha>';
	$xml .= '		<flgerlog>0</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADSCR", "VALIDASENHACOORD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$mtdErro = 'bloqueiaFundo( $(\'#divRotina\') ); $(\'#operauto\',\'#frmSenha\').focus();';
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	}else{
		echo "fechaRotina($('#divRotina'));";
		echo "hideMsgAguardo();";
	}
	
?>