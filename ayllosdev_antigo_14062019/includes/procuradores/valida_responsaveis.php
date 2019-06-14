<?php
	/*!
	 * FONTE        : valida_responsaveis.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : 25/08/2016
	 * OBJETIVO     : Validacao de Representantes/Procuradores
	 *
	 * ALTERACOES   : 31/08/2016 - Alteracao da procedure para parametro de quantidade minima de ass. conjunta,
	 *							   SD.514239 (Jean Michel). 
	 *
	 */
	
	session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once('../controla_secao.php');
	require_once('../../class/xmlfile.php');

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '';
	$flgconju = (isset($_POST['flgconju'])) ? $_POST['flgconju'] : '';
	$qtminast = (isset($_POST['qtminast'])) ? $_POST['qtminast'] : '0';
	
	$xml  = "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0058.p</Bo>";
	$xml .= "		<Proc>valida_responsaveis</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';			
	$xml .= '		<dscpfcgc>'.$nrcpfcgc.'</dscpfcgc>';			
	$xml .= '		<flgconju>'.$flgconju.'</flgconju>';			
	$xml .= '		<qtminast>'.$qtminast.'</qtminast>';
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
			echo 'showConfirmacao("H&aacute; transa&ccedil;&otilde;es pendentes de aprova&ccedil;&atilde;o. Deseja confirmar a altera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","salvarPoderes()","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}else if($xmlObj->roottag->tags[0]->attributes['FLGPENDE'] == 1){
			echo 'showConfirmacao("Deseja confirmar a altera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","salvarPoderes()","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}else if($xmlObj->roottag->tags[0]->attributes['FLGPENDE'] == 2){
			echo 'showConfirmacao("Revise a senha de acesso a Conta Online do novo respons&aacute;vel pela assinatura conjunta. Deseja confirmar a altera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","salvarPoderes()","blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));","sim.gif","nao.gif");';
		}
	}
	
?>