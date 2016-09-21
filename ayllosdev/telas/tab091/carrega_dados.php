<?php

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Adriano                                                  
	  Data : Agosto/2011                       �ltima Altera��o: 		   
	                                                                   
	  Objetivo  : Carregar os dados da tela TAB091.              
	                                                                 
	  Altera��es: 										   			  
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0110.p</Bo>";
	$xmlCarregaDados .= "    <Proc>busca_tab091</Proc>";
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
	} 
	
	$dados = $xmlObjCarregaDados->roottag->tags[0]->tags;
	
	$dstextab = $xmlObjCarregaDados->roottag->tags[0]->attributes["DSTEXTAB"];
	
	$dsdemail = explode(",", $dstextab);
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
	
		 
?>

<script type="text/javascript">	
	$('#dsemail1','#frmTab091').val('<? echo $dsdemail[0] ?>');
	$('#dsemail2','#frmTab091').val('<? echo $dsdemail[1] ?>');
	$('#dsemail3','#frmTab091').val('<? echo $dsdemail[2] ?>');
			
</script>

