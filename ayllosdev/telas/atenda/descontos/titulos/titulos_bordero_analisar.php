<?php 

	/************************************************************************
	 Fonte: titulos_bordero_analisar.php                       
	 Autor: GFT - André Ávila                                                 
	 Data : Abril/2008                Última Alteração: 14/04/2018
	                                                                  
	 Objetivo  : Analisar um bordero de desconto de títulos            
	                                                                  
							  
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");

	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrborder"])){

		exibeErro("Par&acirc;metros incorretos.");
	}

	$cddopcao = $_POST["cddopcao"];
	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];

	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o indicador do tipo de impressão é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lido.");
	}


	// Carrega permissões do operador
	include("../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	if( ($cddopcao == "N") && (in_array('N', $glbvars['opcoesTela'])) ) {

		$xmlLiberacao .= "<Root>";
		$xmlLiberacao .= "	<Dados>";
		$xmlLiberacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlLiberacao .= "		<nrborder>".$nrborder."</nrborder>";	
		$xmlLiberacao .= "	</Dados>";
		$xmlLiberacao .= "</Root>";
			
		$procedure_acao = 'EFETUA_ANALISE_BORDERO';
		$pakage = 'TELA_ATENDA_DESCTO';

		$xmlResult = mensageria($xmlLiberacao, $pakage, $procedure_acao,  $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	} 

	// Cria objeto para classe de tratamento de XML
	$xmlObjLiberacao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLiberacao->roottag->tags[0]->name) == "ERRO") {

		$msgErro = $xmlObjLiberacao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(htmlentities($msgErro));
	} 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 

		echo 'hideMsgAguardo();';
		echo 'habilitaBotaoLiberar(\'N\');';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>