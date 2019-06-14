<?php 

	/************************************************************************
	 Fonte: historico_de_participacao_evento.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                &Uacute;ltima Altera&ccedil;&atilde;o:   /  /     
	                                                                  
	 Objetivo  : Mostrar a op&ccedil;&atilde;o hist&oacute;rico de participa&ccedil;&atilde;o
	                                                                  	 
	 Altera&ccedil;&otilde;es:                                                      
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["inianoev"]) ||
		!isset($_POST["finanoev"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$inianoev = $_POST["inianoev"];
	$finanoev = $_POST["finanoev"];	

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o ano inicial &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inianoev)) {
		exibeErro("Ano in&iacute;cio da pesquisa inv&aacute;lido.");
	}

	// Verifica se o ano final &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($finanoev)) {
		exibeErro("Ano fim da pesquisa inv&aacute;lido.");
	}
	
	if ($inianoev > $finanoev){
		exibeErro("Ano in&iacute;cio deve ser maior que ano fim.");
	}

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetDadosEventosEmAndamento  = "";
	$xmlGetDadosEventosEmAndamento .= "<Root>";
	$xmlGetDadosEventosEmAndamento .= "	<Cabecalho>";
	$xmlGetDadosEventosEmAndamento .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetDadosEventosEmAndamento .= "		<Proc>lista-eventos</Proc>";
	$xmlGetDadosEventosEmAndamento .= "	</Cabecalho>";
	$xmlGetDadosEventosEmAndamento .= "	<Dados>";
	$xmlGetDadosEventosEmAndamento .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosEventosEmAndamento .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosEventosEmAndamento .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosEventosEmAndamento .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosEventosEmAndamento .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosEventosEmAndamento .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosEventosEmAndamento .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosEventosEmAndamento .= "		<inianoev>".$inianoev."</inianoev>"; // Ano atual para trazer por 
	$xmlGetDadosEventosEmAndamento .= "		<finanoev>".$finanoev."</finanoev>"; // default os eventos do ano
	$xmlGetDadosEventosEmAndamento .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosEventosEmAndamento .= "	</Dados>";
	$xmlGetDadosEventosEmAndamento .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosEventosEmAndamento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosEventosEmAndamento = getObjectXML($xmlResult);
	
	$eventos = $xmlObjDadosEventosEmAndamento->roottag->tags[0]->tags;
	
	// Remove todos options do select
	echo "removerOptions('dsevento');";
	
	// Adiciona o option em branco
	echo "adicionarOption('dsevento','optDefault','0,0','');";
	
	for ($i = 0; $i < count($eventos); $i++){
		echo "adicionarOption('dsevento','".$eventos[$i]->tags[1]->cdata."_".$eventos[$i]->tags[2]->cdata."','".$eventos[$i]->tags[1]->cdata.",".$eventos[$i]->tags[2]->cdata."','".$eventos[$i]->tags[0]->cdata."');";
	}
	
	// Coloca o option em branco como selecionado
	//echo 'document.getElementById("optDefault").selected=true;';
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosEventosEmAndamento->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosEventosEmAndamento->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'removerOptions("dsevento");';
		echo 'hideMsgAguardo();';		
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
?>