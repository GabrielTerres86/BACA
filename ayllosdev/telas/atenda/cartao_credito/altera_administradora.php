<?php
	/*!
	 * FONTE        : altera_administradora.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : Marco/2014
	 * OBJETIVO     : Efetua Downgrade ou Upgrade de administradora de cartões
	 * --------------
	 * ALTERAÇÕES   : Incluso regra para efetuar reload da tela de cartoes (Daniel)
	 * --------------
	 * 000: ----- 
	 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro,false);
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["codaadmi"]) || !isset($_POST["codnadmi"]) || !isset($_POST["nrcrcard"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro,false);
	}	
	
	$nrdconta        = $_POST["nrdconta"];
	$codaadmi        = $_POST["codaadmi"];
	$codnadmi        = $_POST["codnadmi"];
	$nrcrcard        = $_POST["nrcrcard"];
	$nrctrcrd_updown = $_POST["nrctrcrd_updown"];
	$contrato        = $_POST["contrato"];
	$dsjustificativa = $_POST['dsjustificativa'];
    $piloto 		 = $_POST['piloto'];
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	if (!validaInteiro($codaadmi)) exibirErro('error','Antiga administradora inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	if (!validaInteiro($codnadmi)) exibirErro('error','Nova administradora inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	if (!validaInteiro($nrcrcard)) exibirErro('error','Cart&atilde; inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);

	// Monta o xml de requisição
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA_CRD", "ENVIO_CARTAO_COOP_PA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$coop_envia_cartao = getByTagName($xmlObjeto->roottag->tags,"COOP_ENVIO_CARTAO");
	

    // Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>altera_administradora</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<codaadmi>".$codaadmi."</codaadmi>";
	$xmlSetCartao .= "		<codnadmi>".$codnadmi."</codnadmi>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata.".",'Alerta - Aimaro',$funcaoAposErro,false);	
	}

	$nrctrcrd = 0;
	if (!empty($xmlObjCartao->roottag->tags[0]->attributes["NRCTRCRD"])) {
		$nrctrcrd = $xmlObjCartao->roottag->tags[0]->attributes["NRCTRCRD"];
	}
	if ($nrctrcrd <= 0) {
		showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","voltaDiv(0,1,4);acessaOpcaoAba(0,1,4);");
	}

	//CODIGO TEMPORARIO - so mandaremos para a esteira se for piloto.
	if ($piloto == 1) {
		echo "atualizaUpgradeDowngrade(".$contrato.", ".$nrctrcrd.");";
	} else {
		if ($coop_envia_cartao) {
			echo "nrctrcrd = " . $nrctrcrd . "; nrctrcrd_updown = ".$nrctrcrd_updown."; consultaEnderecos(2);";
		} else {
			showError("inform","Operacao realizada com sucesso.","Alerta - Aimaro","voltaDiv(0,1,4);acessaOpcaoAba(0,1,4);");
		}
	}
	
?>