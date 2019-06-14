<?php

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Henrique                                                  
	  Data : Maio/2011                       Última Alteração: 27/07/2015
	                                                                   
	  Objetivo  : Carregar os dados da tela ESKECI.              
	                                                                 
	  Alterações: 05/11/2013 - Adicionado paramentro cdoperad em chamada da 
				  proc. busca-cartao (Jorge).
				  
				  27/07/2015 - Removido o campo vlsaqmax. (James)
	                                                                  
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrcartao = $_POST["nrcartao"];
	
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0098.p</Bo>";
	$xmlCarregaDados .= "    <Proc>busca-cartao</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	 <nrcartao>".$nrcartao."</nrcartao>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Esconder a mensagem que carrega contratos 
	echo 'hideMsgAguardo();';
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjCarregaDados->roottag->tags[0]->tags[0];
	
	echo "$('#nrdconta','#frmEskeci').val('".formataContaDV(getByTagName($dados->tags,'nrdconta'))."');";
	echo "$('#nrdctitg','#frmEskeci').val('".mascara(getByTagName($dados->tags,'nrdctitg'),"#.###.###-#")." ".getByTagName($dados->tags,'dssititg')."');";
	echo "$('#nmprimtl','#frmEskeci').val('".getByTagName($dados->tags,'nmprimtl')."');";
	echo "$('#nmtitcrd','#frmEskeci').val('".getByTagName($dados->tags,'nmtitcrd')."');";	
	echo "$('#dtemscar','#frmEskeci').val('".getByTagName($dados->tags,'dtemscar')."');";
	echo "$('#dtvalcar','#frmEskeci').val('".getByTagName($dados->tags,'dtvalcar')."');";
	
	echo "habilitaAlteracao();";
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
	
?>