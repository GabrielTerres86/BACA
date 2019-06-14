<?php 

	/***************************************************************************
	 Fonte: aplicacoes_programadas_alterar_validar.php                             
	 Autor: David                                                     
	 Data : Março/2010                   Ultima Alteracao: 27/07/2018  	                                                                  
	                                                                  
	 Objetivo  : Validar dados para alterar aplicação programada     
	                                                                  
	 Alterações: 04/04/2018 - Chamada da rotina para verificar o range permitido para 
				              contratação do produto. PRJ366 (Lombardi).
				 
				 27/07/2018 - Derivação para Aplicação Programada

				 18/09/2018 - Possibilidade de se alterar valores, finalidade e data de débito
				 			  Proj. 411.2 (CIS Corporte) 
				 
	***************************************************************************/
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["vlprerpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$vlprerpp = $_POST["vlprerpp"];	
	$cdprodut = $_POST["cdprodut"];
	$indebito = $_POST["indebito"];
	$dsfinali = $_POST["dsfinali"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Verifica se a data de débito é um inteiro válido e dentro da faixa
	if ((!validaInteiro($indebito)) or ($indebito<1) or ($indebito>31)) {
		exibeErro("Dia de d&eacutebito inv&aacute;lido.");
	}

	
	// Verifica se o valor da prestação é um decimal válido
	if (!validaDecimal($vlprerpp)) {
		exibeErro("Valor de presta&ccedil;&atilde;o inv&aacute;lido.");
	}					
	
	// Validações unificadas - Datas e valores
	
	$vlcontra = str_replace(',','.',str_replace('.','',$vlprerpp));
	
	// Montar o xml de Requisicao
	$xmlAlterar  = "<Root>";
	$xmlAlterar .= " <Dados>";	
	$xmlAlterar .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlAlterar .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlAlterar .= "   <nrctrrpp>".$nrctrrpp."</nrctrrpp>"; 			
	$xmlAlterar .= "   <indebito>".$indebito."</indebito>"; 			
	$xmlAlterar .= "   <vlprerpp>".$vlcontra."</vlprerpp>";
	$xmlAlterar .= " </Dados>";
	$xmlAlterar .= "</Root>";
	$xmlResult = mensageria($xmlAlterar, "CADA0006", "VALIDA_ALTERACAO_APL_PROG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjAlterar = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr?tica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	}
	
	$solcoord = $xmlObjAlterar->roottag->tags[0]->cdata;
	$mensagem = $xmlObjAlterar->roottag->tags[1]->cdata;
	$dtdebito = $xmlObjAlterar->roottag->tags[2]->cdata;

	// Esconde mensagem de aguardo
	$executar = "hideMsgAguardo();";
	
	// Confirma operação
	$executar .= "showConfirmacao(\"Deseja alterar a aplica&ccedil;&atilde;o programada?\",\"Confirma&ccedil;&atilde;o - Aimaro\",\"alterarAplicacao(\\\"".$vlprerpp."\\\",\\\"".$dtdebito."\\\")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
	
	// Se ocorrer um erro, mostra crítica
	if ($mensagem != "") {
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		
		exibirErro("error",$mensagem,"Alerta - Aimaro", ($solcoord == 1 ? "senhaCoordenador(\\\"".$executar."\\\");" : ""),false);
	} else {
		echo $executar;
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
