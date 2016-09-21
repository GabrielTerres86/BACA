<?php 

	/****************************************************************
	 Fonte: valida_responsaveis.php
	 Autor: Jean Michel
	 Data : Novembro/2015               �ltima Altera��o: 25/08/2016
	                                                                 
	 Objetivo  : Validacao de responsaveis por assinatura conjunta
	                                                                  
	 Altera��es: 25/08/2016 - Ajustes nos parametros da BO e nova validacao para
							  transacoes pendentes, SD 510426(Jean Michel).

	 ****************************************************************/	
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	$dscpfcgc = !isset($_POST["dscpfcgc"]) ? 0 : $_POST["dscpfcgc"];
	$nrdconta = !isset($_POST["nrdconta"]) ? 0 : $_POST["nrdconta"];
	$flgconju = !isset($_POST["flgconju"]) ? 0 : $_POST["flgconju"];
	$qtminast = (isset($_POST['qtminast'])) ? $_POST['qtminast'] : '0';
		
	//Validacao de responsaveis por assinatura conjunta
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0058.p</Bo>";
	$xml .= "		<Proc>valida_responsaveis</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "		<dscpfcgc>".$dscpfcgc."</dscpfcgc>";
	$xml .= "		<flgconju>".$flgconju."</flgconju>";	
	$xml .= "		<qtminast>".$qtminast."</qtminast>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";	                            
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));',false);
	}else{
		if($xmlObj->roottag->tags[0]->attributes['FLGPENDE'] == 0){
			echo 'showConfirmacao("Confirma atualiza&ccedil;&atilde;o dos respons&aacute;veis pela assinatura conjunta?","Confirma&ccedil;&atilde;o - Ayllos","salvarRepresentantes()","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}else{
			echo 'showConfirmacao("Essa conta possui transa��es pendentes de aprova��o.<br><br>Se o poder de assinatura conjunta for modificado essas transa��es<br>n�o poder�o ser aprovadas e ficar�o pendentes at� o prazo de expira��o.<br><br>Confirma a altera��o no poder de assinatura conjunta?","Confirma&ccedil;&atilde;o - Ayllos","salvarRepresentantes()","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}
	}

?>