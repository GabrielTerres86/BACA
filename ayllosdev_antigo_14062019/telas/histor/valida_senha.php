<? 
/*!
 * FONTE        : valida_senha.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 05/04/2018
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
	$operauto	= (isset($_POST['operauto'])) ? $_POST['operauto'] : '' ;
	$codsenha 	= (isset($_POST['codsenha'])) ? $_POST['codsenha'] : '' ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'])) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdoperad>".$operauto."</cdoperad>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "BLQJ0002", "VALIDA_OPERADOR_JURIDICO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

		//-----------------------------------------------------------------------------------------------
		// Controle de Erros
		//-----------------------------------------------------------------------------------------------

	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}		
		exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));',false);
		exit();
	}else{

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

		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
			$mtdErro = 'bloqueiaFundo( $(\'#divRotina\') ); $(\'#operauto\',\'#frmSenha\').focus();';
			$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
		}else{
			echo "fechaRotina($('#divRotina'));";
			echo "hideMsgAguardo();";
		}
	}
	
?>