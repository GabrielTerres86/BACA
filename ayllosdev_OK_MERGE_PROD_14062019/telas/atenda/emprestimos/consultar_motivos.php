<?php 

	/************************************************************************
	 Fonte: consultar_motivos.php                          
	 Autor: Mateus Zimmermann (Mouts)
	 Data : Agosto/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Carregar motivos de anulação
	                                                                  	 
	
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	require_once("../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0 ;

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctremp)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= "   	 <tpproduto>1</tpproduto>";
	$xml .= '        <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '        <nrctrato>'.$nrctremp.'</nrctrato>';
	$xml .= '	    <tpctrlim></tpctrlim>';
	$xml .= '    </Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "EMPR0001", "EMPR0001_BUSCA_MOTIVOS_ANULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','',false);
	}
	
	$motivos = $xmlObjeto->roottag->tags;

	$inaltera = getByTagName($xmlObjeto->roottag->tags[0]->tags,'inaltera');
	
	include("form_motivos.php");
	
?>