<?php 

	/**********************************************************************
	  Fonte: entregar_entregarcartao.php
	  Autor: Guilherme
	  Data : Abri/2007                		Última Alteração: 24/06/2014

	  Objetivo  :	Entregar Cartão de Crédito - rotina de Cartão
	                de Crédito da tela ATENDA

	  Alterações: 14/05/2009 - Alterar nome dtvalchr para dtvalida (David)
	  
                  04/11/2010 - Adaptação Cartão PJ (David)
				  
			      09/09/2011 - Incluido a chamada para a procedure alerta_fraude
							   (Adriano).
							   
				  19/06/2012 - Adicionado confirmacao para impressao (Jorge)
				  
				  11/04/2013 - Retirado a chamada da procedure alerta_fraude
							   (Adriano).
							   
				  24/06/2014 - Ajuste para verificar qual procedure ira fazer 
							   a entrega de cartao. (James)
	***********************************************************************/

	 session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"F")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["cdadmcrd"]) || !isset($_POST["nrcrcard"]) || 
	    !isset($_POST["dtvalida"]) || !isset($_POST["nrcpfrep"]) || !isset($_POST["inpessoa"]) || !isset($_POST["nrcpfcgc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	$nrdconta = $_POST["nrdconta"];
	$inpessoa = $_POST["inpessoa"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$cdadmcrd = $_POST["cdadmcrd"];
	$nrcpfrep = $_POST["nrcpfrep"];
	$nrcrcard = $_POST["nrcrcard"];
	$dtvalida = $_POST["dtvalida"];
	$nrcpfcgc = $_POST["nrcpfcgc"];

	/// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se administrador é um inteiro válido
	if (!validaInteiro($cdadmcrd)) {
		exibeErro("C&oacute;digo da administradora inv&aacute;lido.");
	}
	
	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfrep)) {
		exibeErro("CPF do representante inv&aacute;lido.");
	}	
	
	// Verifica se número do cartão é um inteiro válido
	if (!validaInteiro($nrcrcard)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}	

	// Verifica se data de validade é um inteiro válido
	if (!validaInteiro($dtvalida)) {
		exibeErro("Data de validade inv&aacute;lida.");
	}
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}

	// Administradora Bancoob
	if (($cdadmcrd >= 10) && ($cdadmcrd <= 80)){
		$procedure = "entrega_cartao_bancoob";
	}else{
		$procedure = "entrega_cartao";
	}
	
	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>".$procedure."</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<dtvalida>".$dtvalida."</dtvalida>";
	$xmlSetCartao .= "		<nrcpfrep>".$nrcpfrep."</nrcpfrep>";
	$xmlSetCartao .= "		<inpessoa>".$inpessoa."</inpessoa>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	if ($cdadmcrd == 1) {  // Administradora Credicard 
		$idimpres = 5; 
	} else if ($cdadmcrd == 2) {  // BRADESCO/VISA 
		$idimpres = 2; 
	} else if ($cdadmcrd == 3) {  // CECRED/VISA 
		$idimpres = $inpessoa == 1 ? 2 : 9;  // Imprime termo de entrega para pessoa jurídicas
	} else if (($cdadmcrd >= 10) && ($cdadmcrd <= 80)){
		$idimpres = 18;
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$gerarimpr = 'gerarImpressao(2,'.$idimpres.','.$cdadmcrd.','.$nrctrcrd.',0);';
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	
	echo "callafterCartaoCredito = \"".$acessaaba."\";";
	
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>