<?php 

	/*********************************************************************************
	 Fonte: aplicacao_controlar.php                                     
	 Autor: David                                                     
	 Data : Outubro/2010                 �ltima Altera��o: 16/06/2014
	                                                                  
	 Objetivo  : Script para excluir nova aplica��o                   	
	                                                                  	 
	 Altera��es: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p   
	                          para a BO b1wgen0081.p (Adriano).      

				 16/06/2014 - Ajustes referente ao projeto de capta��o.
							  (Adriano)
							  
				 24/02/2015 - Ajustes para os novos produtos de capta��o
							  (Jean Michel).

				 17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 

	********************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	$cddopcao = "";
			
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || 
	    !isset($_POST["flgvalid"]) || 
		!isset($_POST["nraplica"]) ||
		!isset($_POST["cddopcao"]) ||
		!isset($_POST["tpaplica"]) || 
		!isset($_POST["qtdiaapl"]) || 
		!isset($_POST["dtresgat"]) || 
		!isset($_POST["qtdiacar"]) || 
		!isset($_POST["flgdebci"]) || 
		!isset($_POST["vllanmto"]) ||
		!isset($_POST['idtipapl'])) {
		
		exibeErro("Par&acirc;metros incorretos.");
		$frm = "#frmDadosAplicacao";
	}	
	
	$nrdconta = $_POST["nrdconta"];	
	$flgvalid = $_POST["flgvalid"];
	$cddopcao = $_POST["cddopcao"];
	$tpaplica = $_POST["tpaplica"];
	$nraplica = $_POST["nraplica"];	
	$qtdiaapl = $_POST["qtdiaapl"];
	$dtresgat = $_POST["dtresgat"];
	$qtdiacar = $_POST["qtdiacar"];
	$cdperapl = $_POST["cdperapl"];
	$flgdebci = $_POST["flgdebci"];
	$vllanmto = $_POST["vllanmto"];	
	$idtipapl = $_POST["idtipapl"];
	
	if ($idtipapl == "A"){
	
		if($tpaplica == 7){
			$frm = "#frmDadosAplicacaoPre";
		}else{
			$frm = "#frmDadosAplicacaoPos";
		}
				
	}else{
		$frm = "#frmDadosAplicacaoPos";
	}
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	if ($cddopcao == "E") {		
		// Verifica se n�mero da aplica��o � um inteiro v�lido
		if (!validaInteiro($nraplica)) {
			exibeErro("Aplica&ccedil;&atilde;o inv&aacute;lida.");
		}
	}else{	
		
		// Verifica se tipo de aplica��o � um inteiro v�lido
		if (!validaInteiro($tpaplica)) {
			exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.");
		}
		
		// Verifica se quantidade de dias � um inteiro v�lido
		
		if (!validaInteiro($qtdiaapl)) {
			exibeErro("Quantidade de dias inv&aacute;lida.");
		}		
		
		// Verifica se data de vencimento � v�lida
		if ($cddopcao == "I" && !validaData($dtresgat)) {
			exibeErro("Data de vencimento inv&aacute;lida.");
		}
		
		// Verifica se car�ncia � um inteiro v�lido
		if (!validaInteiro($qtdiacar)) {
			exibeErro("Car&ecirc;ncia inv&aacute;lida.");
		}
		
		
		// Verifica se identificador para conta investimento � v�lido
		if ($flgdebci == 1) {
			$flgdebci = 'true';
		}else{
			$flgdebci = 'false';
		}
		
		// Verifica se valor da aplica��o � um decimal v�lido
		if (!validaDecimal($vllanmto)) {
			exibeErro("Valor inv&aacute;lido.");
		}		
	}
	
	if ($flgvalid == "true") {
		$procedure = "validar-nova-aplicacao";
	} else {
		$procedure = $cddopcao == "I" ? "incluir-nova-aplicacao" : "excluir-nova-aplicacao";
	}
		
	$xmlAplicacao  = "";
	$xmlAplicacao .= "<Root>";
	$xmlAplicacao .= "	<Cabecalho>";
	$xmlAplicacao .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlAplicacao .= "		<Proc>".$procedure."</Proc>";
	$xmlAplicacao .= "	</Cabecalho>";
	$xmlAplicacao .= "	<Dados>";
	$xmlAplicacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAplicacao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlAplicacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAplicacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAplicacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAplicacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlAplicacao .= "		<inproces>".$glbvars["inproces"]."</inproces>";	
	$xmlAplicacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAplicacao .= "		<idseqttl>1</idseqttl>";				
	$xmlAplicacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlAplicacao .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlAplicacao .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xmlAplicacao .= "		<tpaplica>".$tpaplica."</tpaplica>";
	$xmlAplicacao .= "		<nraplica>".$nraplica."</nraplica>";
	$xmlAplicacao .= "		<qtdiaapl>".$qtdiaapl."</qtdiaapl>";
	$xmlAplicacao .= "		<dtresgat>".$dtresgat."</dtresgat>";
	$xmlAplicacao .= "		<qtdiacar>".$qtdiacar."</qtdiacar>";
	$xmlAplicacao .= "		<cdperapl>".$cdperapl."</cdperapl>";
	$xmlAplicacao .= "		<flgdebci>".$flgdebci."</flgdebci>";
	$xmlAplicacao .= "		<vllanmto>".$vllanmto."</vllanmto>";
	$xmlAplicacao .= "	</Dados>";
	$xmlAplicacao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAplicacao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAplicacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAplicacao->roottag->tags[0]->name) == "ERRO") {		
		$msgErro = $xmlObjAplicacao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if($msgErro == null || $msgErro == ""){
			$msgErro = $xmlObjPermanencia->roottag->tags[0]->cdata;
		}
		
		exibeErro($msgErro);
		
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	
	// Bloqueia conte�do que est� �tras do div da rotina
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Pega mensagens de confirma��o/notifica��o
	$msgConfirma = $xmlObjAplicacao->roottag->tags[0]->tags;
	$qtMsgConf   = count($msgConfirma);
	
	echo 'msgAplica = new Array();';
			
	for ($i = 0; $i < $qtMsgConf; $i++) {
		echo 'var objConf = new Object();';
		echo 'objConf.inconfir = '.$msgConfirma[$i]->tags[0]->cdata.';';
		echo 'objConf.dsmensag = "'.$msgConfirma[$i]->tags[1]->cdata.'";';
		echo 'msgAplica['.$i.'] = objConf;';
	}
	
	if ($flgvalid == "true") { // Opera��o de Valida��o			
		echo 'confirmaOperacaoAplicacao("'.$cddopcao.'",0);';		
	} else {		
		echo 'idLinha  = -1;';
		echo 'nraplica = 0;';			
		echo 'notificaOperacaoAplicacao(0);';				
	}

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		global $cddopcao;
		
		if ($cddopcao == "E" || $cddopcao == "") {
			$funcao = "voltarDivPrincipal()";
		} else {
			$funcao = "$('#vllanmto','".$frm."').focus();blockBackground(parseInt($('#divRotina').css('z-index')))";
		}		
		
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro .'","Alerta - Ayllos","'.$funcao.'");';
		
		exit();
	}
	
?>