<?
/*!
 * FONTE        : verifica_acesso_tela_taa.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Julho/2015
 * OBJETIVO     : Verifica o acesso da tela do TAA
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
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"U")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	$nrdconta = $_POST["nrdconta"]; // Número da conta
	$nrcrcard = $_POST["nrcrcard"]; // Número do cartao
	$nrctrcrd = $_POST["nrctrcrd"]; // Número da Proposta
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}

    // Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>verifica_acesso_tela_taa</Proc>";
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
	    exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);');		
	}
	
	$oDados   = $xmlObjCartao->roottag->tags[0];
	$inacetaa = $oDados->attributes["INACETAA"];
	
	require_once('form_taa.php');
?>
<script type="text/javascript">
// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cart&otilde;es
$("#divConteudoCartoes").css("display","none");

controlaLayout('fieldsetTAA');
// Esconde mensagem de aguardo
hideMsgAguardo();
// Bloqueia conteúdo que está atrás do div da rotina
bloqueiaFundo(divRotina);
</script>