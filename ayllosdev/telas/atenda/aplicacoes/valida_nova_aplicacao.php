<?php 

	/*******************************************************************************************
	  Fonte: valida_nova_aplicacao.php                                
	  Autor: Jean Michel                                                     
	  Data : Agosto/2014                 �ltima Altera��o: 07/08/2014
	                                                                   
	  Objetivo  : Script para validacao da proposta de aplicacao de novos produtos de captacao
	                                                                   	 
	  Altera��es:
							   
	********************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	

	$cddopcao = isset($_POST["cddopcao"]) ? $_POST["cddopcao"] : 0; /* Codigo da Opcao */	
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0; /* N�mero da Conta */
	$idseqttl = isset($_POST["idseqttl"]) ? $_POST["idseqttl"] : 0; /* Titular da Conta */
	$cdprodut = isset($_POST["cdprodut"]) ? $_POST["cdprodut"] : 0;	/* C�digo do Produto */	
	$qtdiaapl = isset($_POST["qtdiaapl"]) ? $_POST["qtdiaapl"] : 0;	/* Dias da Aplica��o */		
	$dtvencto = isset($_POST["dtvencto"]) ? $_POST["dtvencto"] : 0; /* Data de Vencimento da Aplica��o */
	$qtdiacar = isset($_POST["qtdiacar"]) ? $_POST["qtdiacar"] : 0; /* Car�ncia da Aplica��o */
	$qtdiaprz = isset($_POST["qtdiaprz"]) ? $_POST["qtdiaprz"] : 0; /* Prazo da Aplica��o */
	$vlaplica = isset($_POST["vlaplica"]) ? $_POST["vlaplica"] : 0; /* Valor da Aplica��o */
	$iddebcti = isset($_POST["iddebcti"]) ? $_POST["iddebcti"] : 0; /* Identificador de D�bito na Conta Investimento */
	$idorirec = isset($_POST["idorirec"]) ? $_POST["idorirec"] : 0; /* Identificador de Origem do Recurso */
	$idgerlog = isset($_POST["idgerlog"]) ? $_POST["idgerlog"] : 0; /* Identificador de Log */
	$flgvalid = isset($_POST["flgvalid"]) ? $_POST["flgvalid"] : 'true';	/* Identificador de validacao ou inclusao de aplicacao */
		
	$vlaplica = str_replace(',','.',str_replace('.','',$vlaplica));
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "   <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
    $xml .= "   <cdprodut>".$cdprodut."</cdprodut>";
    $xml .= "   <qtdiaapl>".$qtdiaapl."</qtdiaapl>";
    $xml .= "   <dtvencto>".$dtvencto."</dtvencto>";
    $xml .= "   <qtdiacar>".$qtdiacar."</qtdiacar>";
    $xml .= "   <qtdiaprz>".$qtdiaprz."</qtdiaprz>";
    $xml .= "   <vlaplica>".$vlaplica."</vlaplica>";
    $xml .= "   <iddebcti>".$iddebcti."</iddebcti>";
    $xml .= "   <idorirec>".$idorirec."</idorirec>";
    $xml .= "   <idgerlog>".$idgerlog."</idgerlog>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	if($flgvalid == 'true'){
		$nmdeacao = 'VALAPL';
	}else{
		$nmdeacao = 'INSAPL';
	}
		
	$xmlResult = mensageria($xml, "ATENDA", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");$xmlObj = getObjectXML($xmlResult);
	
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
		if($flgvalid == 'true'){
			echo 'confirmaOperacaoAplicacao("I",0);';
		}else{
			echo 'hideMsgAguardo();';
			echo 'acessaRotina("APLICACOES","Aplica&ccedil;&otilde;es","aplicacoes");';
		}
	}	
		
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","$(\'#vllanmto\',\''.$frm.'\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>