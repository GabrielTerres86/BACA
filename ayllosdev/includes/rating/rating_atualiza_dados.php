<?php 

	//************************************************************************//
	//*** Fonte: rating_atualiza_dados.php                                 ***//
	//*** Autor: David                                                     ***//
	//*** Data : Abril/2010                   Última Alteração: 22/10/2010 ***//
	//***                                                                  ***//
	//*** Objetivo  : Atualizar dados do rating do cooperado               ***//	
	//***                                                                  ***//
	//*** Alterações: 22/10/2010 - Incluir novo parametro para a funcao    ***//
	//***                          getDataXML (David).                     ***//
	//************************************************************************//

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../config.php");
	require_once("../funcoes.php");		
	require_once("../controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrinfcad"]) || !isset($_POST["nrpatlvr"]) || 
	    !isset($_POST["nrperger"]) || !isset($_POST["nrctrrat"]) || !isset($_POST["tpctrrat"]) ||
		!isset($_POST["iddivcri"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrinfcad = $_POST["nrinfcad"];
	$nrpatlvr = $_POST["nrpatlvr"];
	$nrperger = $_POST["nrperger"];
	$nrctrrat = $_POST["nrctrrat"];
	$tpctrrat = $_POST["tpctrrat"];
	$iddivcri = $_POST["iddivcri"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se identificador de informação cadastral é um inteiro válido
	if (!validaInteiro($nrinfcad)) {
		exibeErro("Informa&ccedil;&etilde;o cadastral inv&aacute;lida.");
	}
	
	// Verifica se identificador de patrimônio é um inteiro válido
	if (!validaInteiro($nrpatlvr)) {
		exibeErro("Patrim&ocirc;nio pessoal inv&aacute;lido.");
	}
	
	// Verifica se identificador de percepção é um inteiro válido
	if (!validaInteiro($nrperger)) {
		exibeErro("Percep&ccedil;&atilde;o geral inv&aacute;lida.");
	}	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($tpctrrat)) {
		exibeErro("Indicador de tipo de contrato para rating inv&aacute;lido.");
	}
	
	// Verifica se número da contrato é um inteiro válido
	if (!validaInteiro($nrctrrat)) {
		exibeErro("N&uacute;mero de contrato para rating inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlRating  = "";
	$xmlRating .= "<Root>";
	$xmlRating .= "  <Cabecalho>";
	$xmlRating .= "    <Bo>b1wgen0043.p</Bo>";
	$xmlRating .= "    <Proc>atualiza_valores_rating</Proc>";
	$xmlRating .= "  </Cabecalho>";
	$xmlRating .= "  <Dados>";
	$xmlRating .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRating .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRating .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRating .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlRating .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlRating .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlRating .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlRating .= "    <idseqttl>1</idseqttl>";	
	$xmlRating .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlRating .= "    <inproces>".$glbvars["inproces"]."</inproces>";	
	$xmlRating .= "    <nrinfcad>".$nrinfcad."</nrinfcad>";		
	$xmlRating .= "    <nrpatlvr>".$nrpatlvr."</nrpatlvr>";
	$xmlRating .= "    <nrperger>".$nrperger."</nrperger>";	
	$xmlRating .= "    <nrctrrat>".$nrctrrat."</nrctrrat>";
	$xmlRating .= "    <tpctrrat>".$tpctrrat."</tpctrrat>";
	$xmlRating .= "  </Dados>";
	$xmlRating .= "</Root>";	
 
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRating,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRating = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") { 		
		// Monta tabela com críticas do rating
		include ("rating_tabela_criticas.php");		
	} else {
		// Encerra mensagem de aguardo e bloqueia fundo da rotina
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
		
		// Aciona função para continuidade da operação
		echo 'eval(fncRatingSuccess);';
	}		
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>