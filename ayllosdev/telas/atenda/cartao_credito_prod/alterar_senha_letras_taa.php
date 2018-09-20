<?
/*!
 * FONTE        : alterar_senha_letras_taa.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Julho/2015
 * OBJETIVO     : Alterar a senha letras do TAA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$nrdconta = $_POST["nrdconta"]; // Número da conta
	$nrctrcrd = $_POST["nrctrcrd"]; // Número da proposta
	$nrcrcard = $_POST["nrcrcard"]; // Número do cartao
	$dssennov = $_POST["dssennov"];
	$dssencon = $_POST["dssencon"];
	$operacao = $_POST['operacao'];
	
	$opcao = 'G';
	if ($operacao == 'entregarCartao'){
	   $opcao = 'F';
	}else if ($operacao == 'liberarAcessoTaa'){
	   $opcao = 'O';
	}
		
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$opcao)) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}

    // Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>grava_dados_senha_letras_taa</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<dssennov>".$dssennov."</dssennov>";
	$xmlSetCartao .= "		<dssencon>".$dssencon."</dssencon>";
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
	
	if (($operacao == 'cadastrarSenhaLetrasTaa') || ($operacao == 'liberarAcessoTaa')) {
		echo "showError('inform','Letras cadastradas com sucesso.','Alerta - Aimaro','opcaoTAA()');";
		
	}else if ($operacao == 'entregarCartao'){
		echo "abreTelaLimiteSaque();";
	}
?>