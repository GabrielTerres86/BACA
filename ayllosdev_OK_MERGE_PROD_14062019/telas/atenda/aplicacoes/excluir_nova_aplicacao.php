<?php 

	/************************************************************************
	 Fonte: excluir_nova_aplicacao.php                                 
	 Autor: Jean Michel                                                     
	 Data : Setembro/2014                 Última Alteração: 08/09/2014
	                                                                  
	 Objetivo  : Exclusão de novas aplicações
	                                                                   
	 Alterações:
							  
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
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["cddopcao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];
	$cddopcao = $_POST["cddopcao"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se número da aplicação é um inteiro válido
	if (!validaInteiro($nraplica)) {
		exibeErro("Aplica&ccedil;&atilde;o inv&aacute;lida.");
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; /* Número da Conta */
	$xml .= "   <nraplica>".$nraplica."</nraplica>"; /* Número da Aplicacao */
    $xml .= "   <idgerlog>1</idgerlog>"; 		     /* Identificador de LOG */
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "EXCAPLI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");$xmlObj = getObjectXML($xmlResult);
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}	
		exibirErro('error',$msgErro,'Alerta - Aimaro','acessaRotina(\"APLICACOES\",\"Aplica&ccedil;&otilde;es\",\"aplicacoes\");',false);
		exit();
	}else{
		echo 'hideMsgAguardo();';
		echo 'acessaRotina("APLICACOES","Aplica&ccedil;&otilde;es","aplicacoes");';
	} 
	
?>