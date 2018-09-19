<?php

	/*************************************************************************
	  Fonte: gera_pagamentos.php                                               
	  Autor: Marcelo L. Pereira                                                  
	  Data : Agosto/2011                       Última Alteração: 10/06/2014
	                                                                   
	  Objetivo  : Gera o pagamento das parcelas.
	                                                                 
	  Alterações: 								

	  [24/05/2013] Lucas R. (CECRED): Incluir camada nas includes "../".
	  [04/11/2013] Adriano  (CECRED): Incluído a passagem do parâmetro cdpactra.
	  [10/06/2014] James	(CECRED): Ajuste para enviar a sequencia do avalista como parametro na procedure "gera_pagamentos_parcelas". (James)
	                                                                  
	***********************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Dados necessários
	$nrdconta = $_POST["nrdconta"];
	$nrctremp = $_POST["nrctremp"];
	$idseqttl = $_POST["idseqttl"];
	$camposPc = $_POST["campospc"];
	$dadosPrc = $_POST["dadosprc"];
	$totatual = $_POST["totatual"];
	$totpagto = $_POST['totpagto'];
	$nrseqavl = $_POST['nrseqavl'];	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Cabecalho>";
	$xml .= "    <Bo>b1wgen0084a.p</Bo>";
	$xml .= "    <Proc>gera_pagamentos_parcelas</Proc>";
	$xml .= " </Cabecalho>";
	$xml .= " <Dados>";
	$xml .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "	<cdpactra>".$glbvars["cdpactra"]."</cdpactra>";
	$xml .= "	<nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "	<idseqttl>".$idseqttl."</idseqttl>";	
	$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "	<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";
	$xml .= "	<flgerlog>TRUE</flgerlog>";
	$xml .= "	<nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "	<totatual>".$totatual."</totatual>";
	$xml .= "	<totpagto>".$totpagto."</totpagto>";
	$xml .= "	<nrseqava>".$nrseqavl."</nrseqava>";
	$xml .= retornaXmlFilhos( $camposPc, $dadosPrc, 'Pagamentos', 'Itens');
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);removeOpacidade(\'divConteudoOpcao\');fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'));',false);
	}
	echo "fechaRotina($('#divUsoGenerico'),$('#divRotina')); verificarImpAntecip();";
?>