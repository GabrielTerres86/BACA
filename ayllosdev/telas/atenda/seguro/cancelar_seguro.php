<?php
/*************************************************************************
*  Fonte: cancelar_seguro.php                                               
*  Autor: Rogério Giacomini de Almeida                                                  
*  Data : 21/09/2011                       Última Alteração: 28/06/2012		   
*                                                                   
*  Objetivo : Cancelar um seguro (Tela ATENDA / SEGURO).
*                                                                 
*  Alterações: 28/06/2012 - Alterado funcao de confirmacao de cancelamento (Jorge)								   			  
				  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)

*                                                                  
***********************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Dados necessários
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$tpseguro = $_POST["tpseguro"];
	$nrctrseg = $_POST["nrctrseg"];
	$motivcan = $_POST["motivcan"];
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Cabecalho>";
	$xml .= "    <Bo>b1wgen0033.p</Bo>";
	$xml .= "    <Proc>cancelar_seguro</Proc>";
	$xml .= " </Cabecalho>";
	$xml .= " <Dados>";
	$xml .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "	<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xml .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "	<idorigem>".$glbvars['idorigem']."</idorigem>";
	$xml .= "	<flgerlog>FALSE</flgerlog>";
	$xml .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	<tpseguro>".$tpseguro."</tpseguro>";
	$xml .= "	<nrctrseg>".$nrctrseg."</nrctrseg>";
	$xml .= "	<cdmotcan>".$motivcan."</cdmotcan>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
			
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
		$mtdErro = "fechaMotivoCancelamento();controlaOperacao('')";
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$mtdErro,false);
	}
	
	echo "fechaMotivoCancelamento();	
		  showConfirmacao('Deseja imprimir o termo de cancelamento?','Confirma&ccedil;&atilde;o - Ayllos','imprimirTermoCancelamento();','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));controlaOperacao(\'\');','sim.gif','nao.gif');";
?>