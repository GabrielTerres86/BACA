<?php

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Henrique                                                  
	  Data : Agosto/2011                       Última Alteração:  13/09/2017
	                                                                   
	  Objetivo  : Carregar os dados da tela TAB042.              
	                                                                 
	  Alterações: 13/09/2017 - Correcao na validacao de permissoes na tela. SD 750528 (Carlos Rafael Tanholi).
	                                                                  
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
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}	

	//recupera a opcao de tela
	$cddopcao = ( isset($_POST["cddopcao"]) ) ? $_POST["cddopcao"] : 'C';
	$msgErro = '';	
	
	if (($msgErro = validaPermissao($glbvars["nmdatela"],' ',$cddopcao,false)) <> '') {
		exibeErro($msgErro);
	}
	
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0106.p</Bo>";
	$xmlCarregaDados .= "    <Proc>busca_tab042</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	
	// Esconder a mensagem que carrega contratos 
	//echo 'hideMsgAguardo();';
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjCarregaDados->roottag->tags[0]->tags;
	
	$dstextab = $xmlObjCarregaDados->roottag->tags[0]->attributes["DSTEXTAB"];
?>
<script type="text/javascript">	
	$('#dstextab','#frmTab042').val('<? echo $dstextab ?>');
</script>