<?php 

	/************************************************************************
	 Fonte: excluir_nova_aplicacao.php                                 
	 Autor: Jean Michel                                                     
	 Data : Setembro/2014                 �ltima Altera��o: 08/09/2014
	                                                                  
	 Objetivo  : Exclus�o de novas aplica��es
	                                                                   
	 Altera��es:
							  
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["cddopcao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];
	$cddopcao = $_POST["cddopcao"];	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se n�mero da aplica��o � um inteiro v�lido
	if (!validaInteiro($nraplica)) {
		exibeErro("Aplica&ccedil;&atilde;o inv&aacute;lida.");
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; /* N�mero da Conta */
	$xml .= "   <nraplica>".$nraplica."</nraplica>"; /* N�mero da Aplicacao */
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
		exibirErro('error',$msgErro,'Alerta - Ayllos','acessaRotina(\"APLICACOES\",\"Aplica&ccedil;&otilde;es\",\"aplicacoes\");',false);
		exit();
	}else{
		echo 'hideMsgAguardo();';
		echo 'acessaRotina("APLICACOES","Aplica&ccedil;&otilde;es","aplicacoes");';
	} 
	
?>