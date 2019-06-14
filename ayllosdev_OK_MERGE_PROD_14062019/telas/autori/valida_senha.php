<? 
/*!
 * FONTE        : valida_senha.php
 * CRIAÇÃO      : Lucas Ranghetti (CECRED)
 * DATA CRIAÇÃO : 15/04/2016
 * OBJETIVO     : Rotina para manter, validar senha do cooperado
 * --------------
 * ALTERAÇÕES   : 16/01/2017 - Arrumar a gravacao da flginassele (Lucas Ranghetti #564654)
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
	$operacao 	= (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$cddsenha 	= (isset($_POST['cddsenha'])) ? $_POST['cddsenha'] : '' ;
	$nrdconta 	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;	
	
	switch($operacao) {
		case 'R5': $retorno = "controlaOperacao('R6');"; break;
		case 'E5': $retorno = "controlaOperacao('E6');"; break;
		case 'I4': $retorno = "controlaOperacao('I5');"; break;
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0092.p</Bo>';
	$xml .= '		<Proc>valida_senha_cooperado</Proc>';
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
	$xml .= '		<cddsenha>'.$cddsenha.'</cddsenha>';
	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$mtdErro = 'bloqueiaFundo( $(\'#divRotina\') ); $(\'#cddsenha\',\'#frmSenha\').focus();';
		echo "flginassele = 0;"; // Nao deve validar senha
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	}else{
		
		echo $retorno;
	}
	
?>