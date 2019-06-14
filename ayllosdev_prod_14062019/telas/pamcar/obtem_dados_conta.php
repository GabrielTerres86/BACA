<?php 
	
	//************************************************************************//
	//*** Fonte: obtem_dados_conta.php                                     ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Dezembro/2011                Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar os dados da conta informada.                  ***//	
	//***                                                                  ***//	 
	//*** Alterações: 26/02/2014 - Tratamento para cooperado demitido      ***//
	//***                          que ainda esta com o convenio ativo.    ***//
	//***                          (Fabricio)                              ***//
	//***                          									       ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}
	
	$nrdconta = $_POST["nrdconta"];
	$nrdctitg = $_POST["nrdctitg"];
	
					
	// Monta o xml de requisição
	$xmlDadosConta  = "";
	$xmlDadosConta .= "<Root>";
	$xmlDadosConta .= "	<Cabecalho>";
	$xmlDadosConta .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlDadosConta .= "		<Proc>obtem_dados_conta</Proc>";
	$xmlDadosConta .= "	</Cabecalho>";
	$xmlDadosConta .= "	<Dados>";
	$xmlDadosConta .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosConta .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";	
	$xmlDadosConta .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosConta .= "		<nrdctitg>".$nrdctitg."</nrdctitg>";
	$xmlDadosConta .= "	</Dados>";
	$xmlDadosConta .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosConta);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosConta = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosConta->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosConta->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$dados = $xmlObjDadosConta->roottag->tags[0]->tags[0]->tags;
	
	// Dados da conta
	echo '$("#nrdconta","#frmHabilita").val("'.$dados[0]->cdata.'").formataDado("INTEGER","zzzz.zzz-z","",false);';
	
	if ($dados[1]->cdata == "")
		echo '$("#nrdctitg","#frmHabilita").val("0.000.000-0");';
	else
		echo '$("#nrdctitg","#frmHabilita").val("'.$dados[1]->cdata.'").formataDado("STRING","9.999.999-9",".-",false);';
		
	echo '$("#dssititg","#frmHabilita").val("'.$dados[2]->cdata.'");';
	echo '$("#nmprimtl","#frmHabilita").val("'.$dados[3]->cdata.'");';
	echo '$("#nrcpfcgc","#frmHabilita").val("'.$dados[4]->cdata.'");';
	
	if ($dados[5]->cdata == "yes")
		echo '$("#flgpamca","#frmHabilita").val("S");';
	else
		echo '$("#flgpamca","#frmHabilita").val("N");';
		
	echo '$("#vllimpaH","#frmHabilita").val("'.number_format(str_replace(",",".",$dados[6]->cdata),2,",",".").'");';
	
	if ($dados[7]->cdata == 0)
		echo '$("#dddebpam","#frmHabilita").val(1);';
	else
		echo '$("#dddebpam","#frmHabilita").val("'.$dados[7]->cdata.'");';
		
	echo '$("#nrctapam","#frmHabilita").val("'.$dados[8]->cdata.'").formataDado("INTEGER","zzzz.zzz-z","",false);';
	
	echo 'cFlgpamca.desabilitaCampo();';
	echo 'cCamposAlteraH.desabilitaCampo();';
	
	// Variáveis globais
	echo 'nrdconta = "'.$dados[0]->cdata.'";';
	echo 'nrdctitg = "'.$dados[1]->cdata.'";';
	echo 'flgdemis = "'.$dados[9]->cdata.'";';
	
	echo 'hideMsgAguardo();';
	
	if (($dados[5]->cdata == "yes") && ($dados[9]->cdata == "yes")) { // se eh um cooperado demitido e possui o convenio ativo.
		echo 'showError("error","Necess&aacute;rio desabilitar este conv&ecirc;nio pois se trata de um cooperado demitido!","Alerta - Ayllos");';
		echo 'cFlgpamca.habilitaCampo();';
		echo 'cFlgpamca.focus();';
		echo 'trocaBotao("Concluir","frmHabilita");';
	
	} elseif (($dados[5]->cdata == "no") && ($dados[9]->cdata == "yes")) // se eh um cooperado demitido e nao possui o convenio ativo.
		exibeErro("Associado demitido!");
	else
		echo 'trocaBotao("Alterar","frmHabilita");'; // nao eh um cooperado demitido... Segue a alteracao...
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}