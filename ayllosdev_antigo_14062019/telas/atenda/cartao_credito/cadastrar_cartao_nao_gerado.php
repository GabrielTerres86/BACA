<?
/*!
 * FONTE        : cadastrar_cartao_nao_gerado.php
 * CRIAÇÃO      : James (CECRED)
 * DATA CRIAÇÃO : Junho/2015
 * OBJETIVO     : Cadastrar Cartão de Crédito Não Gerado
 * --------------
 * ALTERAÇÕES   : 25/04/2016 - Gravar na variavel nrcrcard o número do cartão de crédito. (James)
 * --------------
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
	$params = array('nrdconta','nrctrcrd','nrcrcard','nrcctitg','repsolic');

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {
			exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro,false);
		}
	}
	
	$nrdconta  = $_POST['nrdconta'];	
	$nrctrcrd  = $_POST['nrctrcrd'];
	$nrcrcard  = $_POST['nrcrcard'];
	$nrcctitg  = $_POST['nrcctitg'];
	$nrcctitg2 = $_POST['nrcctitg2'];
	$repsolic  = $_POST['repsolic'];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);	
	if (!validaInteiro($nrcrcard)) exibirErro('error','N&uacute;mero do cart&atilde;o inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);	
	if (!validaInteiro($nrcctitg)) exibirErro('error','N&uacute;mero Conta Cart&atilde;o inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>grava_dados_cartao_nao_gerado</Proc>";
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
	$xmlSetCartao .= "		<nrcctitg>".$nrcctitg."</nrcctitg>";	
	$xmlSetCartao .= "		<nrcctitg2>".$nrcctitg2."</nrcctitg2>";	
	$xmlSetCartao .= "		<repsolic>".$repsolic."</repsolic>";	
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {		
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro,false);	
	}else{
		echo "nrcrcard = " . $nrcrcard . ";bCartaoSituacaoSolicitado = false;";
		echo 'valida_dados_cartao_bancoob();';
	}	
?>
