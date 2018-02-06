<? 
/*!
 * FONTE        : valida_senha.php
 * CRIAÇÃO      : Douglas Quisinski (CECRED)
 * DATA CRIAÇÃO : 09/05/2014
 * OBJETIVO     : Rotina para manter validar senha do operador
 * --------------
 * ALTERAÇÕES   : 06/02/2018 - Ajuste para enviar o nivel do operador como zero, pois não deve valida-lo. Apenas deve-se validar operador/senha (Adriano - SD 845176).
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

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
	$xml .= '		<nvopelib>0</nvopelib>';
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
		

		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "  <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "  <cdoperad>".$operauto."</cdoperad>";
		$xml .= "  <nrdsenha>".$codsenha."</nrdsenha>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "TELA_PRVSAQ", 'PRVSAQ_VAL_OPER', $glbvars['cdcooper'], 1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");				
		$xmlObj = getObjectXML($xmlResult);
		$xmlObj = simplexml_load_string($xmlResult);
				
		$codError = $xmlObj->Erro->Registro->cdcritic;				
		if(isset($codError)){
			$msg = $xmlObj->Erro->Registro->dscritic;
			$mtdErro = 'bloqueiaFundo( $(\'#divRotina\') ); $(\'#operauto\',\'#frmSenha\').focus();';
			exibirErro('error',utf8ToHtml($msg),'Alerta - Ayllos',$mtdErro,false);
		}else{		
			echo "fechaRotina($('#divRotina'));";
			echo "hideMsgAguardo();";
			echo "console.log('".$cddopcao."');";
			if($cddopcao == 'A'){
				echo "manter_rotina('A!!');";
			}
			if($cddopcao == 'I'){
				echo "manter_rotina('I!!!');";	
			}
		}		
	}
?>