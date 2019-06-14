<?php 
	
	//*****************************************************************************************************//
	//*** Fonte: processa_arquivo_debito.php                               							    ***//
	//*** Autor: Fabrício                                                  							    ***//
	//*** Data : Janeiro/2012                					 Última Alteração: 03/02/2012 			***//
	//***                                                                  								***//
	//*** Objetivo  : Processar arquivo de debito dos convenios cadastrados								***//	
	//***                                                                  								***//
	//***                                                                 								***//
	//*** Alterações: 03/02/2012 - Incluido e tratado os parametros de saída: flgsuces, flgjaproc	 	***//
	//***						   (Adriano).   					       								***//
	//***             													   								***//
	//***                          									       								***//
	//*****************************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica permiss&atilde;o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"P");
		
	
	$nmarquiv = $_POST["nmarquiv"];
	
					
	// Monta o xml de requisição
	$xmlProcessaDebito  = "";
	$xmlProcessaDebito .= "<Root>";
	$xmlProcessaDebito .= "	<Cabecalho>";
	$xmlProcessaDebito .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlProcessaDebito .= "		<Proc>processa_arquivo_debito</Proc>";
	$xmlProcessaDebito .= "	</Cabecalho>";
	$xmlProcessaDebito .= "	<Dados>";
	$xmlProcessaDebito .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlProcessaDebito .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlProcessaDebito .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlProcessaDebito .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlProcessaDebito .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlProcessaDebito .= "		<nmarquiv>".$nmarquiv."</nmarquiv>";
	$xmlProcessaDebito .= "	</Dados>";
	$xmlProcessaDebito .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlProcessaDebito);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjProcessaDebito = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjProcessaDebito->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjProcessaDebito->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	
	$flgrejei = $xmlObjProcessaDebito->roottag->tags[0]->attributes["FLGREJEI"];
	$flgsuces = $xmlObjProcessaDebito->roottag->tags[0]->attributes["FLGSUCES"];
	$flgjapro = $xmlObjProcessaDebito->roottag->tags[0]->attributes["FLGJAPRO"];
	
	
	if($flgsuces == "yes"){
		echo 'showError("error","Processado com sucesso.","Alerta - Ayllos");';
	}else{
			if ($flgrejei == "yes"){
				echo 'showError("error","Processamento com inconsist&ecirc;ncias, consulte o relat&oacute;rio.","Alerta - Ayllos");';
			}else{
				if($flgjapro == "yes"){
					echo 'showError("error","Arquivo j&aacute; processado.","Alerta - Ayllos");';
	
				}else{
						echo 'showError("error","Arquivo n&atilde;o foi processado.","Alerta - Ayllos");';
				}
			}
		}	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>