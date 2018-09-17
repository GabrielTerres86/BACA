<? 
/*!
 * FONTE        : libera_acesso.php
 * CRIAÇÃO      : Adriano (CECRED)
 * DATA CRIAÇÃO : 22/08/2012
 * OBJETIVO     : Rotina limpar o dstextab da tab094 e liberar acesso a tela.
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

	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdmovmto = (isset($_POST['cdmovmto'])) ? $_POST['cdmovmto'] : '' ;
	$cdcoopex = (isset($_POST['cdcoopex'])) ? $_POST['cdcoopex'] : '' ;
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}

	//Monta o XML de requisição 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0131.p</Bo>";
	$xml .= "        <Proc>libera_acesso</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "       <cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "       <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "       <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	
	
	if($cdmovmto <> "A" && $glbvars['cdcooper'] == 3){
		$xml .= "       <cdcoopex>".$cdcoopex."</cdcoopex>";
	}else{
		$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	}
		
	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
		
	}			
		
		
?>
	
	
	
	
