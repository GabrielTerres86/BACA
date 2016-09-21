<?
/*!
 * FONTE        : valida_senha_letras_taa.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : Agosto/2015
 * OBJETIVO     : Valida os dados para digitacao da senha de letras do cartao para o TAA
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
	$nrcrcard = $_POST["nrcrcard"]; // N�mero da proposta	
	$nrctrcrd = $_POST["nrctrcrd"]; // N�mero do contrato
	$operacao = $_POST['operacao'];
	$opcao    = 'G';
	
	if ($operacao == 'liberarAcessoTaa'){
		$opcao = 'O';
	}
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$opcao)) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina);');
	}	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina);');
	}

    // Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_dados_senha_letras_taa</Proc>";
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
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
	    exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);');		
	}
	
	require_once('form_senha_letras.php');
	
?>
<script type="text/javascript">
// Mostra o div da Tela da op��o
$("#divOpcoesDaOpcao4").css("display","block");
// Esconde os cart&otilde;es
$("#divOpcoesDaOpcao1").css("display","none");
// Controla o Layout
controlaLayout('frmSenhaLetrasTAA');
// Esconde mensagem de aguardo
hideMsgAguardo();
// Bloqueia conte�do que est� atr�s do div da rotina
bloqueiaFundo(divRotina);
</script>