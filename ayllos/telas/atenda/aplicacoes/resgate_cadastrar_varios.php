<?php

	//************************************************************************//
	//*** Fonte: resgate_cadastrar_varios.php                              ***//
	//*** Autor: Fabricio                                                  ***//
	//*** Data : Agosto/2011                  Última Alteração: 28/10/2014 ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar e cadastrar varios resgates para aplicação   ***//	
	//***                                                                  ***//	 
	//*** Alterações: 28/10/2014 - Alterado a posição das mensagens de     ***//
	//***                          confirmação no XML de retorno da BO81   ***//
    //***                     (Douglas - Projeto Captação Intermet 2014/2) ***//
    //***                                                                  ***//
	//***			   10/03/2015 - Inclusao de condicao para confirmacao  ***//
	//***							de resgate. (Jean Michel)			   ***//
	//***                                                                  ***//
    //***             18/12/2017 - P404 - Inclusão de Garantia de Cobertura das***//
    //***                          Operações de Crédito (Augusto / Marcos (Supero))***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");		
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["dtresgat"]) || !isset($_POST["flgctain"]) || !isset($_POST["flmensag"]) || !isset($_POST["formargt"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$cdoperad = (isset($_POST["cdoperad"])) ? $_POST["cdoperad"] : "";
	$nrdconta = $_POST["nrdconta"];
	$dtresgat = $_POST["dtresgat"];
	$flgctain = $_POST["flgctain"];
	$flmensag = $_POST["flmensag"];
	$camposPc = $_POST["camposPc"];
	//$dadosPrc = str_replace(".",",",str_replace(",","",$_POST["dadosPrc"]));
	$dadosPrc = $_POST["dadosPrc"];
	$formargt = $_POST["formargt"];
    $tdTotSel = $_POST["tdTotSel"];
	
	if($cdoperad == ""){
		$cdoperad = $glbvars["cdoperad"];
	}
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se a data de resgate é válida
	if (!validaData($dtresgat)) {
		exibeErro("Data do resgate inv&aacute;lida.");
	}	
	
	// Verifica se flag de recebimento em conta investimento é válida
	if ($flgctain <> "yes" && $flgctain <> "no") {
		exibeErro("Identificador de resgate inv&aacute;lido.");
	}

	// Verifica se flag de envio de mensagem é válida
	if ($flmensag <> "yes" && $flmensag <> "no") {
		exibeErro("Identificador de resgate inv&aacute;lido.");
	}
	
  // --------
  
  //nrdconta,nraplica,idseqttl,cdprogra,dtmvtolt,vlresgat,flgerlog,innivblq,vlsldinv

  // Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "		<nraplica>0</nraplica>";
	$xml .= "		<idseqttl>1</idseqttl>";
    $xml .= "		<cdprogra>ATENDA</cdprogra>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<vlresgat>".str_replace(",",".",$tdTotSel)."</vlresgat>";
	$xml .= "		<flgerlog>1</flgerlog>";
	$xml .= "		<innivblq>0</innivblq>";
    $xml .= "		<vlsldinv>0</vlsldinv>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ATENDA", "VALID_RESG_APLICA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
  
	// Se ocorrer um erro, mostra crítica
	if(strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibeErro($msgErro);			
		exit();
	}  
  
  // ---------
	
	// Monta o xml de requisição
	$xmlResgate  = "";
	$xmlResgate .= "<Root>";
	$xmlResgate .= "	<Cabecalho>";
	$xmlResgate .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlResgate .= "		<Proc>cadastrar-varios-resgates-aplicacao</Proc>";
	$xmlResgate .= "	</Cabecalho>";
	$xmlResgate .= "	<Dados>";
	$xmlResgate .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlResgate .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlResgate .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlResgate .= "		<cdoperad>".$cdoperad."</cdoperad>";
	$xmlResgate .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlResgate .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlResgate .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlResgate .= "		<idseqttl>1</idseqttl>";
	$xmlResgate .= "		<dtresgat>".$dtresgat."</dtresgat>";
	$xmlResgate .= "		<flgctain>".$flgctain."</flgctain>";
	$xmlResgate .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlResgate .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlResgate .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
	$xmlResgate .= "		<flmensag>".$flmensag."</flmensag>";
	$xmlResgate .= retornaXmlFilhos($camposPc, $dadosPrc, 'Dados_Resgate', 'Itens');
	$xmlResgate .= "	</Dados>";
	$xmlResgate .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlResgate);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjResgate = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjResgate->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjResgate->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	
	if ($flmensag == "yes") {		
		
		$msgConfirma = $xmlObjResgate->roottag->tags[1]->tags;
		
		if (count($msgConfirma) > 1) {
			echo 'var metodoConfirm = \'showConfirmacao("'.$msgConfirma[0]->tags[1]->cdata.'","Confirma&ccedil;&atilde;o - Ayllos","cadastrarVariosResgates(\\\''.$formargt.'\\\',\\\'no\\\',\\\''.$nrdconta.'\\\',\\\''.$dtresgat.'\\\',\\\''.$flgctain.'\\\')","blockBackground(parseInt($(\\\'#divRotina\\\').css(\\\'z-index\\\')))","sim.gif","nao.gif");\';';
			
			// Quebrar mensagem em duas linhas
			$strMsg = $msgConfirma[1]->tags[1]->cdata;
			$strMsg = trim(substr($strMsg,0,strpos($strMsg,".") + 1))."<br>".trim(substr($strMsg,strpos($strMsg,".") + 1));

			echo 'showError("inform","'.$strMsg.'","Notifica&ccedil;&atilde;o - Ayllos",metodoConfirm);';			
		} else {
			$msg = $msgConfirma[0]->tags[1]->cdata;
			if($msg == '' || $msg == null){
				echo 'showConfirmacao("Confima opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","cadastrarVariosResgates(\''.$formargt.'\',\'no\',\''.$nrdconta.'\',\''.$dtresgat.'\',\''.$flgctain.'\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
			}else{
				echo 'showConfirmacao("'.$msg.'","Confirma&ccedil;&atilde;o - Ayllos","cadastrarVariosResgates(\''.$formargt.'\',\'no\',\''.$nrdconta.'\',\''.$dtresgat.'\',\''.$flgctain.'\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
			}
			
		}
	} else {
		echo 'flgoprgt = true;';
		
		// Bloqueia conteúdo que está atrás do div da rotina
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
		
		// Voltar para opção geral de resgate
		echo 'voltarDivResgateAutoManual("true");';
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>