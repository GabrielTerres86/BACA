<?php 

	/****************************************************************
	 Fonte: valida_responsaveis.php
	 Autor: Jean Michel
	 Data : Novembro/2015               Última Alteração: 25/08/2016
	                                                                 
	 Objetivo  : Validacao de responsaveis por assinatura conjunta
	                                                                  
	 Alteraçães: 25/08/2016 - Ajustes nos parametros da BO e nova validacao para
							  transacoes pendentes, SD 510426(Jean Michel).

	 ****************************************************************/	
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
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
	// Monta o xml de requisição
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
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));',false);
	}else{
		/*if($xmlObj->roottag->tags[0]->attributes['FLGPENDE'] == 0){
			echo 'showConfirmacao("Confirma atualiza&ccedil;&atilde;o dos respons&aacute;veis pela assinatura conjunta?","Confirma&ccedil;&atilde;o - Aimaro","salvarRepresentantes()","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}else{
			echo 'showConfirmacao("Essa conta possui transações pendentes de aprovação.<br><br>Se o poder de assinatura conjunta for modificado essas transações<br>não poderão ser aprovadas e ficarão pendentes até o prazo de expiração.<br><br>Confirma a alteração no poder de assinatura conjunta?","Confirma&ccedil;&atilde;o - Aimaro","salvarRepresentantes()","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}*/
		if($xmlObj->roottag->tags[0]->attributes['FLGPENDE'] == 0){
			echo 'showConfirmacao("H&aacute; transa&ccedil;&otilde;es pendentes de aprova&ccedil;&atilde;o. Deseja alterar os respons&aacute;veis pela assinatura?","Confirma&ccedil;&atilde;o - Aimaro","salvarRepresentantes();","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}else if($xmlObj->roottag->tags[0]->attributes['FLGPENDE'] == 1){
			echo 'showConfirmacao("Deseja alterar os respons&aacute;veis pela assinatura?","Confirma&ccedil;&atilde;o - Aimaro","salvarRepresentantes();","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}else if($xmlObj->roottag->tags[0]->attributes['FLGPENDE'] == 2){
			echo 'showConfirmacao("Revise as senhas de acesso a Conta Online para os novos respons&aacute;veis. Deseja alterar as permiss&otilde;es de assinatura?","Confirma&ccedil;&atilde;o - Aimaro","salvarRepresentantes();","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}
	}

?>