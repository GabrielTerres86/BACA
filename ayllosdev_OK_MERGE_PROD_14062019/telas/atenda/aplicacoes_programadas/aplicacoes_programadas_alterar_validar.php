<?php 

	/***************************************************************************
	 Fonte: aplicacoes_programadas_alterar_validar.php                             
	 Autor: David                                                     
	 Data : Mar�o/2010                   Ultima Alteracao: 27/07/2018  	                                                                  
	                                                                  
	 Objetivo  : Validar dados para alterar aplica��o programada     
	                                                                  
	 Altera��es: 04/04/2018 - Chamada da rotina para verificar o range permitido para 
				              contrata��o do produto. PRJ366 (Lombardi).
				 
				 27/07/2018 - Deriva��o para Aplica��o Programada

				 18/09/2018 - Possibilidade de se alterar valores, finalidade e data de d�bito
				 			  Proj. 411.2 (CIS Corporte) 
				 
	***************************************************************************/
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["vlprerpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$vlprerpp = $_POST["vlprerpp"];	
	$cdprodut = $_POST["cdprodut"];
	$indebito = $_POST["indebito"];
	$dsfinali = $_POST["dsfinali"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Verifica se a data de d�bito � um inteiro v�lido e dentro da faixa
	if ((!validaInteiro($indebito)) or ($indebito<1) or ($indebito>31)) {
		exibeErro("Dia de d&eacutebito inv&aacute;lido.");
	}

	
	// Verifica se o valor da presta��o � um decimal v�lido
	if (!validaDecimal($vlprerpp)) {
		exibeErro("Valor de presta&ccedil;&atilde;o inv&aacute;lido.");
	}					
	
	// Valida��es unificadas - Datas e valores
	
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
	
	// Confirma opera��o
	$executar .= "showConfirmacao(\"Deseja alterar a aplica&ccedil;&atilde;o programada?\",\"Confirma&ccedil;&atilde;o - Aimaro\",\"alterarAplicacao(\\\"".$vlprerpp."\\\",\\\"".$dtdebito."\\\")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
	
	// Se ocorrer um erro, mostra cr�tica
	if ($mensagem != "") {
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		
		exibirErro("error",$mensagem,"Alerta - Aimaro", ($solcoord == 1 ? "senhaCoordenador(\\\"".$executar."\\\");" : ""),false);
	} else {
		echo $executar;
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
