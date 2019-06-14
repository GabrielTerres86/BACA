<?php 
	/**************************************************************************
	      Fonte: cadastrar_novo_plano.php                                  
	      Autor: David                                                     
	      Data : Outubro/2007                 Ultima Alteracao: 13/11/2018
	                                                                  
		  Objetivo  : Cadastrar Novo Plano de Capital - rotina de Capital da tela ATENDA                                       
	                                                                  	 
	      Alteracoes: 05/06/2012 - Adicionado confirmacao de impressao (Jorge)
					  
					  26/02/2014 - Adicionado atributos $cdtipcor e $vlcorfix, alem da procedure valida-dados-alteracao-plano. (Fabricio)         
					  
					  04/10/2015 - Reformulacao cadastral (Gabriel-RKAM).						
					  
					  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM) 
					  
					  18/07/2016 - Correcao no retorno das informacoes do XML. SD 479874. (Carlos R)

					  22/03/2017 - Ajuste para solicitar a senha do cooperado e não gerar o termo
                                   para coleta da assinatura (Jonata - RKAM / M294).
										   
					  13/11/2017 - Ajuste para gravar o tipo de Autorizacao (Andrey Formigari - Mouts).
	**************************************************************************/
	
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
	$executandoProdutos = $_POST['executandoProdutos'];
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
	
	if ($flcancel == "true")
		$xmlSetPlano .= "		<Proc>altera-plano</Proc>";
	else
		$xmlSetPlano .= "		<Proc>cria-plano</Proc>";
		
	$xmlSetPlano .= "	</Cabecalho>";
	$xmlSetPlano .= "	<Dados>";
	$xmlSetPlano .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPlano .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
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
	$xmlSetPlano .= "		<flgpagto>".$flgpagto."</flgpagto>";
	$xmlSetPlano .= "		<qtpremax>".$qtpremax."</qtpremax>";
	$xmlSetPlano .= "		<dtdpagto>".$dtdpagto."</dtdpagto>";
	$xmlSetPlano .= "		<tpautori>".$tpautori."</tpautori>";
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
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "P"
	$idPrincipal = array_search("P",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		// Usa o primeiro ind&iacute;ce
		$idPrincipal = 0;		
	}
	
	// Mostra conteudo da opcao Principal
	if ($executandoProdutos == 'true') {
		$metodo = 'encerraRotina();';
	} else {
		$metodo = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',\''.$glbvars["opcoesTela"][$idPrincipal].'\');';	
	}
	
	echo "callafterCapital = \"".$metodo."\";";
	
	if($tpautori == "1" ){
	 
	  if ($flcancel == "true"){
			
		 echo 'showError("inform","Plano alterado com sucesso.","Notifica&ccedil;&atilde;o - Aimaro","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));'.$metodo.'");';
    
	  }else{
		
		  echo 'showError("inform","Plano aderido com sucesso.","Notifica&ccedil;&atilde;o - Aimaro","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));'.$metodo.'");';
    
	  }


	}else{
  
	// Chama função para gerar termo de autorização do novo plano			
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","hideMsgAguardo();imprimeNovoPlano();","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));'.$metodo.'","sim.gif","nao.gif");';
	
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>