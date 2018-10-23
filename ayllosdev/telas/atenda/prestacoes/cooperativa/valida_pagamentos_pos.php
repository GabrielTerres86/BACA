<? 
/*!
 * FONTE        : valida_pagamentos_pos.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 21/07/2017
 * OBJETIVO     : Valida dados do pagamento
 *
 * ALTERACOES	: 21/08/2018 - Exibir mensagem de conta em prejuizo
 *				               PJ 450 - Diego Simas - AMcom	 
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P')) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro');
	}
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$vlapagar = (isset($_POST['vlapagar'])) ? $_POST['vlapagar'] : '';

	// Mensageria referente a situa??o de preju?zo	
	// Diego Simas (AMcom) 
	// In?cio  
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_ATENDA_DEPOSVIS", "CONSULTA_PREJU_CC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto = getObjectXML($xmlResult);	

	$param = $xmlObjeto->roottag->tags[0]->tags[0];

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"controlaOperacao('');",false); 
	}else{
		$inprejuz = getByTagName($param->tags,'inprejuz');	    
	}
	
	if($inprejuz == 1 && $vlapagar != 0){
		exibirErro('error',utf8_encode('Conta em prejuízo, pagamento deve ser efetuado através da opção Bloqueado Prejuízo.'),'Alerta - Aimaro',$mtdErro,false);
	}else{
	// Fim
	// Diego Simas (AMcom) 

	    // Montar o xml de Requisicao
        $xml  = "<Root>";
        $xml .= "	<Dados>";
	    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
	    $xml .= "		<vlapagar>".$vlapagar."</vlapagar>";
        $xml .= "	</Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "EMPR0011", "EMPR0011_VALIDA_PAG_POS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
            exibirErro('error',$xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	    } else if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'CONFIRMACAO' ) {
		    echo 'showConfirmacao("'.$xmlObject->roottag->tags[0]->cdata.'","Confirma&ccedil;&atilde;o - Aimaro","verificaAbreTelaPagamentoAvalista();","hideMsgAguardo();bloqueiaFundo(divRotina);","sim.gif","nao.gif");';
	    } else {	
		    echo 'confirmaPagamento();'; 
		}
	
	}
?>