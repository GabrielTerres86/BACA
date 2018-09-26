<?php 

	//************************************************************************//
	//*** Fonte: poupanca_resgate_efetuar.php                              ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2010                   Última Alteração: 26/07/2016 ***//
	//***                                                                  ***//
	//*** Objetivo  : Efetuar resgate para poupança programada             ***//	
	//***                                                                  ***//	 
	//*** Alterações: 22/06/2015 - Substiuido os '.' da string de valor    ***//
	//***                          pois dava problema na validacao         ***//
	//***                          (Tiago/Gielow).                         ***//
	//***                                                                  ***//	 
	//***             18/05/2018 - Validar bloqueio de poupança programada ***//
    //***                          (SM404).                                ***//
	//***                                                                  ***//
	//***			  26/07/2016 - Corrigi o tratamento para retorno de    ***//
	//***						   erro do XML. SD 479874 (Carlos R.)	   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["tpresgat"]) || 
	    !isset($_POST["vlresgat"]) || !isset($_POST["dtresgat"]) || !isset($_POST["flgctain"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$cdoperad = $_POST["cdoperad"];
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$tpresgat = $_POST["tpresgat"];
	$vlresgat = $_POST["vlresgat"];
	$dtresgat = $_POST["dtresgat"];	
	$flgctain = $_POST["flgctain"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	

    /*Nao reconhecia valor que tivesse milhar com '.' na string*/	
    $vlresgat = trim(str_replace('.','',(string)$vlresgat));

	// Verifica se o valor de resgate é um decimal válido
	if (!validaDecimal($vlresgat)) {
		exibeErro("Valor de resgate inv&aacute;lido. ");
	}
	
	// Verifica se a data de resgate é válida
	if (!validaData($dtresgat)) {
		exibeErro("Data de resgate inv&aacute;lida.");
	}			
	
	// Verifica se flag de recebimento em conta investimento é válida
	if ($flgctain <> "yes" && $flgctain <> "no") {
		exibeErro("Identificador de resgate inv&aacute;lido.");
	}
			
	// Monta o xml de requisição
	$xmlResgate  = "";
	$xmlResgate .= "<Root>";
	$xmlResgate .= "	<Cabecalho>";
	$xmlResgate .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlResgate .= "		<Proc>efetuar-resgate</Proc>";
	$xmlResgate .= "	</Cabecalho>";
	$xmlResgate .= "	<Dados>";
	$xmlResgate .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlResgate .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlResgate .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlResgate .= "		<cdoperad>".$cdoperad."</cdoperad>";
	$xmlResgate .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlResgate .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlResgate .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlResgate .= "		<idseqttl>1</idseqttl>";
	$xmlResgate .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlResgate .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlResgate .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";	
	$xmlResgate .= "		<tpresgat>".$tpresgat."</tpresgat>";
	$xmlResgate .= "		<vlresgat>".$vlresgat."</vlresgat>";
	$xmlResgate .= "		<dtresgat>".$dtresgat."</dtresgat>";
	$xmlResgate .= "		<flgctain>".$flgctain."</flgctain>";
	$xmlResgate .= "	</Dados>";
	$xmlResgate .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlResgate);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjResgate = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjResgate->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjResgate->roottag->tags[0]->tags[0]->tags[4]->cdata);
	// Senão, gera log com os dados da autorização e exclui o bloqueio no caso de resgate total (SM404)
	}else{
		if(isset($_SESSION['cdopelib'])) {
			$vlresgat = str_replace(',','.',str_replace('.','',$vlresgat));
			// Montar o xml de Requisicao
			$xml .= "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; // Código da cooperativa
			$xml .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>"; // Código do operador
			$xml .= "   <cdopelib>".$_SESSION['cdopelib']."</cdopelib>"; // Código do coordenador
			$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; // Número da Conta
			$xml .= "   <nraplica>".$nrctrrpp."</nraplica>"; // Número da Aplicação
			$xml .= "   <vlresgat>".$vlresgat."</vlresgat>"; // Valor do resgate
			$xml .= "   <tpresgat>".$tpresgat."</tpresgat>"; // Tipo do resgate
			$xml .= "	<idseqttl>1</idseqttl>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			
			$xmlResult = mensageria($xml, "APLI0002", "PROC_POS_RESGATE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObj = getObjectXML($xmlResult);
		}
						
		//-----------------------------------------------------------------------------------------------
		// Controle de Erros
		//-----------------------------------------------------------------------------------------------
		
		if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			
			exibeErro($msgErro,$frm);			
			exit();
		}
	} 
	
	echo 'flgoprgt = true;';
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	
	// Bloqueia conteúdo que está átras do div da rotina
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Voltar para opção geral de resgate
	echo 'voltarDivResgate();';
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>