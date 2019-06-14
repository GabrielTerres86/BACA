<?php

	/*************************************************************************
	  Fonte: exclui_endereco.php                                               
	  Autor: Henrique                                                  
	  Data : Agosto/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Excluir endereco da tabela CADDNE.              
	                                                                 
	  Alterações: 										   			  
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrdrowid = $_POST["nrdrowid"];
		
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0038.p</Bo>";
	$xmlCarregaDados .= "    <Proc>exclui-endereco-ayllos</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	 <nmdatela>CADDNE</nmdatela>";
	$xmlCarregaDados .= "	 <idorigem>5</idorigem>";
	$xmlCarregaDados .= "	 <nrdconta>0</nrdconta>";
	$xmlCarregaDados .= "	 <idseqttl>0</idseqttl>";
	$xmlCarregaDados .= "	 <flgerlog>TRUE</flgerlog>";
	$xmlCarregaDados .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlCarregaDados .= "	 <nrdrowid>".$nrdrowid."</nrdrowid>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Esconder a mensagem que carrega contratos 
	echo 'hideMsgAguardo();';
	
	$dados = $xmlObjCarregaDados->roottag->tags[0]->tags[0];
	
	$qtdedend = $xmlObjCarregaDados->roottag->tags[0]->attributes["QTDEDEND"];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	echo "showError('inform','Endere&ccedil;o exclu&iacute;do com sucesso.','Exclus&atilde;o de Endere&ccedil;o - Ayllos','150'); estado_inicial();";
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		echo 'estado_inicial();';
		exit();
	}
	
?>