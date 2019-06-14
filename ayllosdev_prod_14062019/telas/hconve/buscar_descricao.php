<?php  
	/*********************************************************************
	 Fonte: buscar_descricao.php                                                 
	 Autor: Jonata - Mouts
	 Data : Outubro/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Buscar descrição do histórico                               
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	
?>
<?php
	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	$cdhistor = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : 0;
	$nomeFormulario    = (isset($_POST["nomeFormulario"])) ? $_POST["nomeFormulario"] : '';
	
	validaDados();
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <cdhistor>".$cdhistor."</cdhistor>";		
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_HCONVE", "PC_HIST_LUPA_OPCAO_H", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','$(\'input, select\',\'#'.$nomeFormulario.'\').removeClass(\'campoErro\');focaCampoErro(\'cdhistor\',\''.$nomeFormulario.'\');',false);		
					
	}

	$dshistor = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[1]->cdata;
	$dsexthst = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[2]->cdata;

	echo "$('#dshistor','#".$nomeFormulario."').val('".$dshistor."');";
	echo "$('#dsexthst','#".$nomeFormulario."').val('".$dsexthst."');";

	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'if( $(\'#divMatric\').css(\'display\') == \'block\' || $(\'#divTela\').css(\'display\') == \'block\' ) { unblockBackground(); }';
	
	function validaDados(){
		
		//Número da conta
        if (  $GLOBALS["cdhistor"] == 0 ){
            exibirErro('error','Hist&oacute;rico inv&aacute;lido.','Alerta - Aimaro','$(\'input, select\',\'#'.$GLOBALS["nomeFormulario"].'\').removeClass(\'campoErro\');focaCampoErro(\'cdhistor\',\''.$GLOBALS["nomeFormulario"].'\');',false);
        } 
		
	}
	
	
?>
	









