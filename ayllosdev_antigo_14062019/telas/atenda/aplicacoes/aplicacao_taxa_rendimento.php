<?php 

	/**********************************************************************************
	   Fonte: aplicacao_taxa_rendimento.php                             
	   Autor: David                                                     
	   Data : Outubro/2010                 Última Alteração: 29/07/2014
	                                                                    
	   Objetivo  : Carregar taxa de rendimento da nova aplicação        	
	                                                                    	 
	   Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p   
                                para a BO b1wgen0081.p (Adriano).       
	                                                                    
	   			  23/08/2013 - Implementação novos produtos Aplicação  
	   					       (Lucas).				

				  11/06/2014 - Ajustes referente ao projeto de captação
							   (Adriano).
							   
				  29/07/2014 - Ajustes referente ao projeto de captação,
							   inclusao de novos parametros e chamada de procedure.
							   (Jean Michel).			   
							   
	************************************************************************************/
	
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpaplica"]) || !isset($_POST["vllanmto"])) {
		exibeErro("Par&acirc;metros incorretos.",$frm);
	}	
	
	$nrdconta = $_POST["nrdconta"];	/*Numero da Conta*/ 
	$tpaplica = $_POST["tpaplica"]; /*Codigo do tipo da aplicacao*/			
	$cdperapl = $_POST["cdperapl"]; /*Codigo de periodo de aplicacao*/
	$vllanmto = $_POST["vllanmto"]; /*Valor da Aplicacao*/
	$idtippro = $_POST["idtippro"]; /*Verifica se produto é PRE OU POS dos produtos novos*/
	$idprodut = $_POST["idprodut"]; /*Verifica se é produto novo ou antigo*/
	$qtdiaprz = $_POST["qtdiaapl"]; /*Prazo de aplicacao*/
	$qtdiaapl = $_POST["qtdiaapl"]; /*Qtd dias de aplicacao*/
	$qtdiacar = $_POST["qtdiacar"];	/*Dias de carencia de aplicacao*/
	
	
	if ($idprodut == "A"){
	
		if($tpaplica == 7){
			$frm = "#frmDadosAplicacaoPre";
		}else{
			$frm = "#frmDadosAplicacaoPos";
		}
			
		// Verifica se código do período da carência é um inteiro válido
		if (!validaInteiro($cdperapl)) {
			exibeErro("C&oacute;digo de per&iacute;odo inv&aacute;lido.",$frm);
		}
	
	}else{
		$frm = "#frmDadosAplicacaoPos";
	}	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.",$frm);
	}
	
	// Verifica se tipo da aplicação é um inteiro válido
	if (!validaInteiro($tpaplica)) {
		exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.",$frm);
	}	
		
	// Verifica se valor da aplicação é um decimal válido
	if (!validaDecimal($vllanmto)) {
		exibeErro("Valor inv&aacute;lido.",$frm);
	}	
	
	if ($idprodut == "A"){
	
		// Monta o xml de requisição
		$xmlAplicacao  = "";
		$xmlAplicacao .= "<Root>";
		$xmlAplicacao .= "	<Cabecalho>";
		$xmlAplicacao .= "		<Bo>b1wgen0081.p</Bo>";
		$xmlAplicacao .= "		<Proc>obtem-taxa-aplicacao</Proc>";
		$xmlAplicacao .= "	</Cabecalho>";
		$xmlAplicacao .= "	<Dados>";
		$xmlAplicacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlAplicacao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlAplicacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlAplicacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlAplicacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlAplicacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlAplicacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlAplicacao .= "		<idseqttl>1</idseqttl>";
		$xmlAplicacao .= "		<tpaplica>".$tpaplica."</tpaplica>";							
		$xmlAplicacao .= "		<cdperapl>".$cdperapl."</cdperapl>";
		$xmlAplicacao .= "		<vllanmto>".$vllanmto."</vllanmto>";	
		$xmlAplicacao .= "	</Dados>";
		$xmlAplicacao .= "</Root>";	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlAplicacao);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjAplicacao = getObjectXML($xmlResult);			
		
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjAplicacao->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjAplicacao->roottag->tags[0]->tags[0]->tags[4]->cdata,$frm);
		} 	
		
		echo 'flgDigitValor = false;';
		echo '$("#txaplica","'.$frm.'").val("'.$xmlObjAplicacao->roottag->tags[0]->attributes["TXAPLICA"].'");';
		echo '$("#dsaplica","'.$frm.'").val("'.$xmlObjAplicacao->roottag->tags[0]->attributes["DSAPLICA"].'");';		
		
		if($tpaplica == 8){
			echo '$("#qtdiaapl","'.$frm.'").val("'.$qtdiaapl.'");';			
			echo 'calculaDataResgate();';			
		} 
		
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';
		
		// Bloqueia conteúdo que está átras do div da rotina
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	}else{
	
		$vllanmto = str_replace(',','.',str_replace('.','',$vllanmto));
		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <cdprodut>".$tpaplica."</cdprodut>";
		$xml .= "   <vlraplic>".$vllanmto."</vlraplic>";
		$xml .= "   <qtdiacar>".$qtdiacar."</qtdiacar>";
		$xml .= "   <qtdiaprz>".$qtdiaprz."</qtdiaprz>";
		$xml .= "   <qtdiaapl>".$qtdiaapl."</qtdiaapl>";		
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "ATENDA", "OBTTAX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
			
		//-----------------------------------------------------------------------------------------------
		// Controle de Erros
		//-----------------------------------------------------------------------------------------------
		
		if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibeErro($msgErro,$frm);
			exit();
		}else{
			$aux_txaplica = number_format(str_replace(",",".",$xmlObj->roottag->tags[0]->tags[0]->cdata),8,",",".");
			
			echo 'flgDigitValor  = false;';
			echo 'flgDigitVencto = false;';
			echo '$("#txaplica","'.$frm.'").val("'.$aux_txaplica.'");';
			echo '$("#dsaplica","'.$frm.'").val("'.$xmlObj->roottag->tags[0]->tags[1]->cdata.'");';
			echo '$("#dtresgat","'.$frm.'").val("'.$xmlObj->roottag->tags[0]->tags[2]->cdata.'");';
			echo '$("#dtcarenc","'.$frm.'").val("'.$xmlObj->roottag->tags[0]->tags[3]->cdata.'");';
			echo '$("#qtdiaapl","'.$frm.'").val("'.$xmlObj->roottag->tags[0]->tags[4]->cdata.'");';
			if ($idprodut == "A"){
				echo '$("#btConcluir","'.$frm.'").focus();';
			}else{
				echo '$("#flgrecno","'.$frm.'").focus();';
			}
		}	
				
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';
		
		// Bloqueia conteúdo que está átras do div da rotina
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	}	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro,$frm) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error",\''.$msgErro.'\',"Alerta - Aimaro","$(\'#vllanmto\',\''.$frm.'\').focus(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>