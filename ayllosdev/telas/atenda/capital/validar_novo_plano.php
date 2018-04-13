<?php 
	//*********************************************************************************************************************************************************//
	//*** Fonte: validar_novo_plano.php                     
	//*** Autor: David                                                     
	//*** Data : Dezembro/2007											  Ultima Alteracao: 18/07/2016
	//***
	//*** Objetivo  : Validar Novo Plano de Capital - rotina de Capital  da tela ATENDA 
	//***                                                                  
	//*** Alteracoes:  26/02/2014 - Adicionado atributos $cdtipcor e $vlcorfix, alem da procedure valida-dados-alteracao-plano.(Fabricio)                            
	//***					    18/07/2016 - Correcao na forma de leitura do retorno XML. SD 479874. (Carlos R).
	//*********************************************************************************************************************************************************//

	/************************************************************************
	 Fonte: validar_novo_plano.php                                   
	 Autor: David                                                    
	 Data : Dezembro/2007                       Última alteração: 22/03/2017
	                                                                 
	 Objetivo  : Validar Novo Plano de Capital - rotina de Capital   
	             da tela ATENDA                                      
	                                                                 
	 Alterações: 26/02/2014 - Adicionado atributos $cdtipcor e      
	                            $vlcorfix, alem da procedure         
	                            valida-dados-alteracao-plano.        
	                            (Fabricio)     
                 18/07/2016 - Correcao na forma de leitura do retorno XML. SD 479874. (Carlos R).  
				            
                 22/03/2017 - Ajuste para solicitar a senha do cooperador e não gerar o termo
                              para coleta da assinatura 
                             (Jonata - RKAM / M294). 
                           
                           
                           
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"P")) <> "") {
		exibeErro($msgError);		
	}		
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["vlprepla"]) || !isset($_POST["cdtipcor"]) || !isset($_POST["flgpagto"]) || !isset($_POST["qtpremax"]) || !isset($_POST["dtdpagto"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$vlprepla = $_POST["vlprepla"];
	$cdtipcor = $_POST["cdtipcor"];
	$vlcorfix = $_POST["vlcorfix"];
	$flgpagto = $_POST["flgpagto"];
	$qtpremax = $_POST["qtpremax"];
	$dtdpagto = $_POST["dtdpagto"];	
	$flcancel = $_POST["flcancel"];
  $tpautori = $_POST["tpautori"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se valor do plano &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vlprepla)) {
		exibeErro("Valor do Plano inv&aacute;lido.");
	}

	if ($cdtipcor == 2)
		if (!validaDecimal($vlcorfix))
			exibeErro("Valor de corre&ccedil;&atilde;o inv&aacute;lido.");
	
	// Valida tipo de d&eacute;bito
	if ($flgpagto <> "yes" && $flgpagto <> "no") {
		exibeErro("Tipo de D&eacute;bito inv&aacute;lido.");
	}
	
	// Verifica se quantidade de presta&ccedil;&otilde;es &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($qtpremax)) {
		exibeErro("Quantidade de presta&ccedil;&otilde;es inv&aacute;lida.");
	}
	
	// Verifica se data de in&iacute;cio do plano &eacute; v&aacute;lida
	if (!validaData($dtdpagto)) {
		exibeErro("Data de In&iacute;cio do pagamento inv&aacute;lida.");
	}
	
  // Verifica o tipo de autoriza&ccedil;&atilde;o
	if ($tpautori != "1" && $tpautori != "2") {
		exibeErro("Tipo de autoriza&ccedil;&atilde;o inv&aacute;lido.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPlano  = "";
	$xmlSetPlano .= "<Root>";
	$xmlSetPlano .= "	<Cabecalho>";
	$xmlSetPlano .= "		<Bo>b1wgen0021.p</Bo>";
	
	if ($flcancel == "false")
		$xmlSetPlano .= "		<Proc>valida-dados-plano</Proc>";
	else
		$xmlSetPlano .= "		<Proc>valida-dados-alteracao-plano</Proc>";
		
	$xmlSetPlano .= "	</Cabecalho>";
	$xmlSetPlano .= "	<Dados>";
	$xmlSetPlano .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPlano .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPlano .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPlano .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPlano .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPlano .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetPlano .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetPlano .= "		<idseqttl>1</idseqttl>";
	$xmlSetPlano .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetPlano .= "		<vlprepla>".$vlprepla."</vlprepla>";
	$xmlSetPlano .= "		<cdtipcor>".$cdtipcor."</cdtipcor>";
	$xmlSetPlano .= "		<vlcorfix>".$vlcorfix."</vlcorfix>";
	
	if ($flcancel == "false") {
		$xmlSetPlano .= "		<flgpagto>".$flgpagto."</flgpagto>";
		$xmlSetPlano .= "		<qtpremax>".$qtpremax."</qtpremax>";
		$xmlSetPlano .= "		<dtdpagto>".$dtdpagto."</dtdpagto>";
	}
	
	$xmlSetPlano .= "		<flgerlog>YES</flgerlog>";
	$xmlSetPlano .= "	</Dados>";
	$xmlSetPlano .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPlano);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPlano = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjPlano->roottag->tags[0]->name) && strtoupper($xmlObjPlano->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPlano->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	
	$vlprepla = str_replace(',','.',str_replace('.','',$vlprepla));
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>".    15   ."</cdprodut>"; //Cobrança Bancária
	$xml .= "   <vlcontra>".$vlprepla."</vlcontra>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_VALOR_ADESAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	}
	
	$solcoord = $xmlObject->roottag->tags[0]->cdata;
	$mensagem = $xmlObject->roottag->tags[1]->cdata;
	
	$executar = "";
	
	if($tpautori == "1") {
		if ($flcancel == "false") {
			// Mensagem para confirmar cadastro do novo plano
			$executar .= "showConfirmacao(\"Deseja cadastrar o novo plano de capital?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"solicitaSenhaMagnetico(\\\"cadastraNovoPlano(".$flcancel.",".$tpautori.")\\\",".$nrdconta.")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
		}else{
			$executar .= "showConfirmacao(\"Deseja alterar o plano de capital?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"solicitaSenhaMagnetico(\\\"cadastraNovoPlano(".$flcancel.",".$tpautori.")\\\",".$nrdconta.")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
		}
	}else{
		if ($flcancel == "false") {
			// Mensagem para confirmar cadastro do novo plano
			$executar .= "showConfirmacao(\"Deseja cadastrar o novo plano de capital?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"cadastraNovoPlano(".$flcancel.",".$tpautori.")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
		}else{
			$executar .= "showConfirmacao(\"Deseja alterar o plano de capital?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"cadastraNovoPlano(".$flcancel.",".$tpautori.")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
		}
	}
	
	// Se ocorrer um erro, mostra crítica
	if ($mensagem != "") {
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		
		exibirErro("error",$mensagem,"Alerta - Ayllos", ($solcoord == 1 ? "senhaCoordenador(\\\"".$executar."\\\");" : ""),false);
	} else {
		echo $executar;
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>