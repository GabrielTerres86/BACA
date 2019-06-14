<?php 

	//************************************************************************//
	//*** Fonte: contas_cadastradas_alterar_validar.php      	       ***//
	//*** Autor: Lucas                                                     ***//
	//*** Data : Maio/2012                   Última Alteração:             ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar dados para alteração de contas de transf     ***//
	//***                                                                  ***//	 
	//***                                                                  ***//	 
	//*** Alterações: 27/04/2015 - Inclusão do campo ISPB SD271603         ***//
        //***                          FDR041 (Vanessa)                        ***//											   ***//	 
	//***                                                                  ***//
	//***                                                                  ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) ||
		!isset($_POST["nrctatrf"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	$cddbanco = $_POST["cddbanco"];
        $cdispbif = $_POST["cdispbif"];
	$cdageban = $_POST["cdageban"];
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$nrctatrf = $_POST["nrctatrf"];
	$nrcpfcgc = $_POST["nrcpfcgc"];	
	$nmtitula = $_POST["nmtitula"];
	$inpessoa = $_POST["inpessoa"];
	$intipcta = $_POST["intipcta"];
	$insitcta = $_POST["insitcta"];
	$intipdif = $_POST["intipdif"];
	$nomeform = $_POST["nomeForm"];
			
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetPendentes  = "";
	$xmlGetPendentes .= "<Root>";
	$xmlGetPendentes .= "	<Cabecalho>";
	$xmlGetPendentes .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetPendentes .= "		<Proc>valida-inclusao-conta-transferencia</Proc>";
	$xmlGetPendentes .= "	</Cabecalho>";
	$xmlGetPendentes .= "	<Dados>";
	$xmlGetPendentes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetPendentes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetPendentes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetPendentes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetPendentes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlGetPendentes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetPendentes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetPendentes .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlGetPendentes .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetPendentes .= "		<cddbanco>".$cddbanco."</cddbanco>";
        $xmlGetPendentes .= "		<cdispbif>".$cdispbif."</cdispbif>";
	$xmlGetPendentes .= "		<cdageban>".$cdageban."</cdageban>";
	$xmlGetPendentes .= "		<nrctatrf>".$nrctatrf."</nrctatrf>";
	$xmlGetPendentes .= "		<intipdif>".$intipdif."</intipdif>";
	$xmlGetPendentes .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlGetPendentes .= "		<inpessoa>".$inpessoa."</inpessoa>";
	$xmlGetPendentes .= "		<intipcta>".$intipcta."</intipcta>";
	$xmlGetPendentes .= "		<insitcta>".$insitcta."</insitcta>";
	$xmlGetPendentes .= "		<flvldinc>false</flvldinc>"; //Não é inclusão de Nova Conta
	$xmlGetPendentes .= "		<nmtitula>".$nmtitula."</nmtitula>";
	$xmlGetPendentes .= "	</Dados>";
	$xmlGetPendentes .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPendentes);

	// Cria objeto para classe de tratamento de XML
	$xmlObjPendentes = getObjectXML($xmlResult);
	
	//Foco no campo de erro
	$nomeCampo = $xmlObjPendentes->roottag->tags[0]->attributes["NMDCAMPO"];
	
	if ( $nomeCampo != '' ) {
		$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeform.'\');bloqueiaFundo(divRotina);';
	} else {
		$mtdErro = 'bloqueiaFundo(divRotina);';
	}

	if ( strtoupper($xmlObjPendentes->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error', $xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
		exit();
	}
	
	//Adquire dados pra exibição
	$registros = $xmlObjPendentes->roottag->tags[0]->tags;
	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
		
	function exibeConfirmacao($intipdif,$nomeform) {
		echo 'hideMsgAguardo();';
		echo 'showConfirmacao("Deseja alterar os dados da Conta?","Confirma&ccedil;&atilde;o - Aimaro","alteraDadosConta('.$intipdif.',\''.$nomeform.'\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		exit();	
	}	
	
	echo 'hideMsgAguardo();';
	exibeConfirmacao($intipdif,$nomeform);
