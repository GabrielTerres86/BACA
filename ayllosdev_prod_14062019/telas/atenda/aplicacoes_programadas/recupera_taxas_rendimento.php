<?php 

	/**********************************************************************************
	   Fonte: taxa_rendimento.php                             
	   Autor: CIS Corporate                                                     
	   Data : Outubro/2018                 ?ltima Altera??o: 
	                                                                    
	   Objetivo  : Carregar taxa de rendimento da nova aplicação programada. 
	   			   Derivado da aplicacao_taxa_rendimento.php
				   Proj. 411.2 - CIS Corporate
	                                                                    	 
	   Altera??es:  
							   
	************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari?veis globais de controle, e biblioteca de fun??es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m?todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	// Se par?metros necess?rios n?o foram informados
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["cdprodut"]) || 
		!isset($_POST["idtippro"]) ||
		!isset($_POST["vlprerpp"]) || 
		!isset($_POST["qtdiaapl"]) ||
		!isset($_POST["qtdiacar"])) {
		exibeErro("Par&acirc;metros incorretos.",$frm);
	}	

	$nrdconta = $_POST["nrdconta"];	/* Numero da Conta*/ 
	$cdprodut = $_POST["cdprodut"]; /* Codigo do produto*/
	$idtippro = $_POST["idtippro"]; /* Produto é PRE OU POS dos produtos novos*/ 
	$vlprerpp = $_POST["vlprerpp"]; /* Valor da Parcela*/
	$qtdiaprz = $_POST["qtdiaapl"]; /* Prazo de aplicacao*/
	$qtdiaapl = $_POST["qtdiaapl"]; /* Qtd dias de aplicacao*/
	$qtdiacar = $_POST["qtdiacar"];	/* Dias de carencia de aplicacao*/
	
	$frm = "#frmDadosPoupanca";
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.",$frm);
	}
	
	// Verifica se produto é um inteiro válido
	if (!validaInteiro($cdprodut)) {
		exibeErro("Produto inv&aacute;lido.",$frm);
	}	
		
	// Verifica se valor da parcela é um decimal válido
	if (!validaDecimal($vlprerpp)) {
		exibeErro("Valor inv&aacute;lido.",$frm);
	}	
	
	$vlprerpp = str_replace(',','.',str_replace('.','',$vlprerpp));
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>".$cdprodut."</cdprodut>";
	$xml .= "   <vlraplic>".$vlprerpp."</vlraplic>";
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
		}	
				
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';
		
		// Bloqueia conteúdo que está atrás do div da rotina
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
		
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro,$frm) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error",\''.$msgErro.'\',"Alerta - Ayllos","$(\'#vlprerpp\',\''.$frm.'\').focus(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>