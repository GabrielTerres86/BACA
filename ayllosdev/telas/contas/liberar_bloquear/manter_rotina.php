<?php 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Liberar/Bloquear da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 06/01/2016 - Ajustar para manter o valor do campo libera credito pre-aprovado(Anderson).
 * --------------			 14/07/2016 - Correcao no acesso ao retorno dos dados XML. SD 479874. Carlos R.
 */		
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$flgrenli = (isset($_POST['flgrenli'])) ? $_POST['flgrenli'] : '';
	$flgcrdpa = (isset($_POST['flgcrdpa'])) ? $_POST['flgcrdpa'] : '';

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "") 
	   exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0193.p</Bo>";					
	$xml .= "		<Proc>grava_dados</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= "		<flgrenli>".$flgrenli."</flgrenli>";
	$xml .= "		<flgcrdpa>".$flgcrdpa."</flgcrdpa>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObject = getObjectXML($xmlResult);
			
	if (isset($xmlObject->roottag->tags[0]->name) && strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	function exibeErro($msgErro) {
		echo 'showError("error"," '.$msgErro.'","Alerta - Contas","$(\'#flgrenli\',\'#frmLiberarBloquear\').focus();hideMsgAguardo();bloqueiaFundo(divRotina);");';
	}
?>
