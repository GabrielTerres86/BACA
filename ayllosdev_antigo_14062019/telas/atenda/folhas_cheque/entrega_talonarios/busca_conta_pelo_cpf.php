<?php 

	/***************************************************************************
	 Fonte: busca_conta_pelo_cpf.php
	 Autor: Lombardi
 	 Data : Agosto/2018                 Última Alteração: 16/08/2018

	 Objetivo  : Rotina para buscar a conta pelo cpf

	 Alterações: 
				
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	include("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrcpfcgc"])){
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E',false)) <> '') 
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	$nrcpfcgc = isset($_POST['nrcpfcgc']) ? $_POST['nrcpfcgc'] : 0;
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CHEQ0001", "CHQ_BUSCA_CONTA_CPF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$nmprimtl = $xmlObject->roottag->tags[0]->cdata;
	echo "$('#nmtercei','#frmEntregaTalonarios').val('".$nmprimtl."');bloqueiaFundo(divRotina);"
?>
