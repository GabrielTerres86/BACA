<?
/*!
 * FONTE        : valida_bloqueio_taa.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : Agosto/2015
 * OBJETIVO     : Valida os dados para bloqueio do cartao para o TAA
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
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"B")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	}
	
	$nrdconta = $_POST["nrdconta"]; // N�mero da conta
	$nrcrcard = $_POST["nrcrcard"]; // N�mero do cartao	
	$nrctrcrd = $_POST["nrctrcrd"]; // N�mero do contrato
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	}

    // Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_dados_bloqueio_taa</Proc>";
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
	    exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);		
	}
	
	echo 'hideMsgAguardo();';
	echo 'bloqueiaFundo(divRotina);';
	echo 'showConfirmacao("Deseja bloquear o acesso ao sistema TAA?","Confirma&ccedil;&atilde;o - Ayllos","bloquearCartaoCreditoTAA()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
?>