<?
/*!
 * FONTE        : alterar_senha_letras_taa.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : Julho/2015
 * OBJETIVO     : Alterar a senha letras do TAA
 * --------------
 * ALTERA��ES   :
 * --------------
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$nrdconta = $_POST["nrdconta"]; // N�mero da conta
	$nrctrcrd = $_POST["nrctrcrd"]; // N�mero da proposta
	$nrcrcard = $_POST["nrcrcard"]; // N�mero do cartao
	$dssennov = $_POST["dssennov"];
	$dssencon = $_POST["dssencon"];
	$operacao = $_POST['operacao'];
	
	$opcao = 'G';
	if ($operacao == 'entregarCartao'){
	   $opcao = 'F';
	}else if ($operacao == 'liberarAcessoTaa'){
	   $opcao = 'O';
	}
		
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$opcao)) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}

    // Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
	    exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
	}
	
	if (($operacao == 'cadastrarSenhaLetrasTaa') || ($operacao == 'liberarAcessoTaa')) {
		echo "showError('inform','Letras cadastradas com sucesso.','Alerta - Aimaro','opcaoTAA()');";
		
	}else if ($operacao == 'entregarCartao'){
		echo "abreTelaLimiteSaque();";
	}
?>