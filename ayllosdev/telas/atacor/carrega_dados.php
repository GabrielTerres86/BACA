<?php

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Henrique                                                  
	  Data : Junho/2011                       �ltima Altera��o: 		   
	                                                                   
	  Objetivo  : Carregar os dados da tela ALTERA.              
	                                                                 
	  Altera��es: 										   			  
	  [27/03/2012] Rog�rius Milit�o (DB1) : Novo layout padr�o, adiciona $returnError com focu no campo conta;
	                                                                  
	***********************************************************************/

	session_start();	
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	$returnError = "$('#nracordo','#frmCabAtacor').focus();";
	$nracordo 	 = $_POST["nracordo"]; // Opcao Utilizada no carrega_dados
	$msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'C');

	if (!empty($msgError)) {		
		exibirErro('error', $msgError, 'Alerta - Atacor', '', false);
	}

    $xml = "<Root>";
    $xml .= "  <Dados>";			
    $xml .= "    <nracordo>".$nracordo."</nracordo>";
    $xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ATACOR", "BUSCA_CONTRATOS_ACORDO", 
							$glbvars["cdcooper"], 
							$glbvars["cdagenci"], 
							$glbvars["nrdcaixa"], 
							$glbvars["idorigem"], 
							$glbvars["cdoperad"], 
							"</Root>");	

	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Atacor',$returnError,false);
	} 
	
	// Lista de contratos retornados para exibi??o na tabela
	$contratos = $xmlObjCarregaDados->roottag->tags[0]->tags[2]->tags;
	
	$nmprimtl = getByTagName($xmlObjCarregaDados->roottag->tags[0]->tags, 'Titular');
	$nrdconta = formataContaDV(getByTagName($xmlObjCarregaDados->roottag->tags[0]->tags, 'Conta'));

	// Se acordo n�o � v�lido ou n�o foi encontrado
	if (empty($nmprimtl)) { 	
		exibirErro('error','Informe um n&uacute;mero de acordo ativo.','Alerta - Atacor',$returnError . "$('#divTabela').hide(); $('#nmprimtl, #nrdconta').val('');",false);
	}

	include "tabela_atacor.php";	
?>

<script type="text/javascript">
	$('#nmprimtl','#frmCabAtacor').val('<? echo $nmprimtl; ?>');
	$('#nrdconta','#frmCabAtacor').val('<? echo $nrdconta; ?>');
	formataTabela();	
	selecionaContrato($('#divTabela tbody:nth-child(0)'));
</script>
