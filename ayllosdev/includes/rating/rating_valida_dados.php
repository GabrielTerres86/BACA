<?php 

	//************************************************************************//
	//*** Fonte: rating_valida_dados.php                                   ***//
	//*** Autor: David                                                     ***//
	//*** Data : Abril/2010                   Última Alteração: 22/10/2010 ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar dados do rating do cooperado                 ***//	
	//***                                                                  ***//
	//*** Alterações: 22/10/2010 - Incluir novo parametro para a funcao    ***//
	//***                          getDataXML (David).                     ***//
	//***                                                                  ***//
	//***             16/04/2015 - Consultas automatizadas (Gabriel-RKAM)  ***//
	//**                                                                   ***//
	//***             26/06/2015 - Ajuste para validar quando consulta ao  ***//
  //**               	           conjuge (Gabriel-RKAM).                 ***//
  //**              18/12/2017 - P404 - Inclusão de Garantia de Cobertura***//
  //**                           das Operações de Crédito                ***//
  //**                           (Augusto / Marcos (Supero))             ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../config.php");
	require_once("../funcoes.php");		
	require_once("../controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");		
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrgarope = isset($_POST["nrgarope"]) ? $_POST["nrgarope"] : 1;
	$nrinfcad = isset($_POST["nrinfcad"]) ? $_POST["nrinfcad"] : 1;
	$nrliquid = isset($_POST["nrliquid"]) ? $_POST["nrliquid"] : 1;
	$nrpatlvr = isset($_POST["nrpatlvr"]) ? $_POST["nrpatlvr"] : 1;
	$nrperger = isset($_POST["nrperger"]) ? $_POST["nrperger"] : 1;	
	$operacao = $_POST['operacao'];
	$inprodut = $_POST['inprodut'];
	$inpessoa = $_POST['inpessoa'];
	$vlprodut = $_POST['vlprodut'];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inválida.");
	}
	
	// Verifica se identificador de garantia é um inteiro válido
	if (!validaInteiro($nrgarope)) {
		exibeErro("Garantia inválida.");
	}
	
	// Verifica se identificador de informação cadastral é um inteiro válido
	if (!validaInteiro($nrinfcad)) {
		exibeErro("Informação cadastral inválida.");
	}
	
	// Verifica se identificador de liquidez é um inteiro válido
	if (!validaInteiro($nrliquid)) {
		exibeErro("Liquidez de garantia inválida.");
	}
	
	// Verifica se identificador de patrimônio é um inteiro válido
	if (!validaInteiro($nrpatlvr)) {
		exibeErro("Patrimônio pessoal inválida.");
	}
	
	// Verifica se identificador de percepção é um inteiro válido
	if (!validaInteiro($nrperger)) {
		exibeErro("Percepção geral inválida.");
	}
	
	// Monta o xml de requisição
	$xmlValidaRating  = "";
	$xmlValidaRating .= "<Root>";
	$xmlValidaRating .= "  <Cabecalho>";
	$xmlValidaRating .= "    <Bo>b1wgen0043.p</Bo>";
	$xmlValidaRating .= "    <Proc>valida-itens-rating</Proc>";
	$xmlValidaRating .= "  </Cabecalho>";
	$xmlValidaRating .= "  <Dados>";
	$xmlValidaRating .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlValidaRating .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlValidaRating .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlValidaRating .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlValidaRating .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlValidaRating .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlValidaRating .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlValidaRating .= "    <idseqttl>1</idseqttl>";
	$xmlValidaRating .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlValidaRating .= "    <nrgarope>".$nrgarope."</nrgarope>";
	$xmlValidaRating .= "    <nrinfcad>".$nrinfcad."</nrinfcad>";
	$xmlValidaRating .= "    <nrliquid>".$nrliquid."</nrliquid>";	
	$xmlValidaRating .= "    <nrpatlvr>".$nrpatlvr."</nrpatlvr>";
	$xmlValidaRating .= "    <nrperger>".$nrperger."</nrperger>";
	$xmlValidaRating .= "  </Dados>";
	$xmlValidaRating .= "</Root>";	
 
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlValidaRating,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRating = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRating->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	if ($operacao == 'I_PROT_CRED' && $inprodut == 3) { // Inclusao na tela do Rating no Limite de credito
	
		$strnomacao = 'SSPC0001_OBRIGACAO_CNS_CPL';
	
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
		$xml .= "    <inprodut>".$inprodut."</inprodut>";
		$xml .= "    <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "    <vlprodut>".$vlprodut."</vlprodut>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "SSPC0001", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
		$xmlObj    = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" && $xmlObj->roottag->tags[0]->cdata != '') {
		  $msgErro = $xmlObj->roottag->tags[0]->cdata;
		  exibirErro('error',$msgErro,'Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))", false);
		}
	
		$xml_geral = simplexml_load_string($xmlResult);
		$inobriga = $xml_geral->inobriga;
				
		// Encerra mensagem de aguardo e bloqueia fundo da rotina
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
		
		if ($inobriga == 'C') { // Contingencia
			echo "controlaOperacao('I_PROTECAO_TIT');";
		} else {
			echo "lcrShowHideDiv('divDadosAvalistas','divDadosRating');$('#nrctaav1','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')));";
		}
		
	} 
	else if ($operacao == 'A_PROT_CRED' && $inprodut == 3) { // Alteracao na tela do Rating no Limite de credito	
		echo 'hideMsgAguardo();';
		echo "controlaOperacao('A_PROTECAO_TIT');";
	} 
	else if ($operacao == 'I_PROTECAO_TIT' && $inprodut == 3) { // Inclusao na tela de Consultas automatizadas
	
		echo '$("#frmOrgaos").css("display","none");';
		echo '$("#divDadosAvalistas").show();';
		echo '$("#nrctaav1","#frmNovoLimite").focus();blockBackground(parseInt($("#divRotina").css("z-index")));';
		
		// Encerra mensagem de aguardo e bloqueia fundo da rotina
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	}
	else if ($operacao == 'A_COMITE_APROV' && $inprodut == 3 )  { // Alteracao na tela de consultas automatizadas
		echo '$("#frmOrgaos").remove();';
		echo '$("#frmNovoLimite").css("width", 530);';
		echo '$("#divDadosAvalistas").css("display","block");';
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	}
	else if ($operacao == 'A_PROTECAO_TIT_CONJ') {
		echo 'controlaOperacao("A_PROTECAO_CONJ");';
	}
	else {
	
		// Esconde div do RATING
		echo '$("#divDadosRating").css("display","none");';
		
		// Aciona função para continuação da operação
		echo 'eval(fncRatingContinue);';
		
		// Encerra mensagem de aguardo e bloqueia fundo da rotina
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	}
	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>