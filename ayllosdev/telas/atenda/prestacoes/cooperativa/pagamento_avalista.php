<? 
/*!
 * FONTE        : pagamento_avalista.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 06/06/2014 
 * OBJETIVO     : Carregar os avalistas para o pagamentos das parcelas 
 * 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	 
?>

<?
    session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0;
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	if (!validaInteiro($nrctremp)) exibirErro('error','Contrato inválido.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0084a.p</Bo>";
	$xml .= "    <Proc>busca_avalista_pagamento_parcela</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "    <idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "    <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"controlaOperacao('C_PAG_PREST');",false); 
		return;
	}

	$avalistas = $xmlObjeto->roottag->tags[0]->tags;
	
	include('tabela_pagamento_avalista.php');
?>	
<script type="text/javascript">
	controlaLayoutPagamentoAvalista();	
</script>