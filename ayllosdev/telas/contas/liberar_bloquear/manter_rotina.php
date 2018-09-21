<?php 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Liberar/Bloquear da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 06/01/2016 - Ajustar para manter o valor do campo libera credito pre-aprovado
 *                             (Anderson).
 *                14/07/2016 - Correcao no acesso ao retorno dos dados XML. SD 479874. Carlos R.
 *				  27/07/2016 - Adicionados novos campos para a fase 3 do projeto pre aprovado
 *                             (Lombardi).
 * --------------
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
	$flgrenli = (isset($_POST['flgrenli'])) ? $_POST['flgrenli'] : '0';
	$flgcrdpa = (isset($_POST['flgcrdpa'])) ? $_POST['flgcrdpa'] : '0';
	
	$flgrenli = strtoupper($flgrenli) == 'NO' ? 0 : 1;
	$flgcrdpa = strtoupper($flgcrdpa) == 'NO' ? 0 : 1;
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "") 
	   exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= "		<flgrenli>".$flgrenli."</flgrenli>";
	$xml .= "		<flgcrdpa>".$flgcrdpa."</flgcrdpa>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_CONTAS_DESAB", "DESOPE_GRAVA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibeErro($msgErro);
	}
	
	function exibeErro($msgErro) {
		echo 'showError("error"," '.$msgErro.'","Alerta - Contas","$(\'#flgrenli\',\'#frmLiberarBloquear\').focus();hideMsgAguardo();bloqueiaFundo(divRotina);");';
	}
?>
