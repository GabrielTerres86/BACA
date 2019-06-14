<?
/*!
 * FONTE        : valida_dados_cartao_bancoob.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Maio/2014
 * OBJETIVO     : Validar os dados do cartão de credito bancoob.
 * --------------
 * ALTERAÇÕES   : 26/06/2015 - Ajuste na mensagem de confirmacao. (James)
 * --------------
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"F")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	$nrdconta = $_POST["nrdconta"]; // Número da conta
	$nrctrcrd = $_POST["nrctrcrd"]; // Número da proposta
	$nrcrcard = $_POST["nrcrcard"]; // Número do cartão de crédito
	$dtvalida = $_POST["dtvalida"]; // Data de Validade
	$flgcchip = $_POST["flgcchip"]; // Define se a entrega do cartão de crédito será com chip ou sem chip
	$flag2via = $_POST["flag2via"]; // Define se será a segunda Via
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	if (!validaInteiro($nrcrcard)) {
		exibirErro('error','N&uacute;mero do cart&atilde;o inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
	}
	
    // Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_entrega_cartao_bancoob</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<dtvalida>".$dtvalida."</dtvalida>";
	$xmlSetCartao .= "		<flag2via>".$flag2via."</flag2via>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
	    exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
	}
	
	$oDados    = $xmlObjCartao->roottag->tags[0];
	$flpurcrd = ((strtoupper($oDados->attributes["FLPURCRD"]) == 'YES') ? 1 : 0);
	
	$mensagem = $oDados->tags[0]->tags[1]->cdata;
	if (!empty($mensagem)){
		$metodoYes = (($flgcchip) ? 'altera_senha_pinpad();' : 'efetuaEntregaCartaoSemChip();');
		echo 'flpurcrd = ' . $flpurcrd . ';';
		echo 'showConfirmacao("'.$mensagem.'","Confirma&ccedil;&atilde;o - Aimaro","'.$metodoYes.'","validaVoltaTela();","sim.gif","nao.gif");';	
	}
?>