<?php 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Liberar/Bloquear da tela de ATENDA
 * --------------
 * ALTERAÇÕES   : 06/01/2016 - Ajustar para manter o valor do campo libera credito pre-aprovado
 *                             (Anderson).
 *                14/07/2016 - Correcao no acesso ao retorno dos dados XML. SD 479874. Carlos R.
 *				  27/07/2016 - Adicionados novos campos para a fase 3 do projeto pre aprovado
 *                             (Lombardi).
 *                08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 *				  09/11/2017 - Ajuste para remover acentos e caracteres especiais do campo
 *                             dsmotmaj. Chamado 783434 - Mateus Z (Mouts)
 *
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
	$flgrenli = (isset($_POST['flgrenli'])) ? $_POST['flgrenli'] : '0';
	$flgcrdpa = (isset($_POST['flgcrdpa'])) ? $_POST['flgcrdpa'] : '0';
	$flmajora = (isset($_POST['flmajora'])) ? $_POST['flmajora'] : '1';
	$dsmotmaj = (isset($_POST['dsmotmaj'])) ? $_POST['dsmotmaj'] : '';
	
	$dsmotmaj = utf8_decode($dsmotmaj);
	$dsmotmaj = removeCaracteresInvalidos($dsmotmaj);
	$dsmotmaj = retiraAcentos($dsmotmaj);

	$flgrenli = strtoupper($flgrenli) == 'NO' ? 0 : 1;
	$flgcrdpa = strtoupper($flgcrdpa) == 'NO' ? 0 : 1;
	$flmajora = strtoupper($flmajora) == 'NO' ? 0 : 1;
	
	if ($operacao == 'ALTERARC' && $flmajora == 0 && $dsmotmaj == '')
	  exibirErro('error',"&Eacute; obrigat&oacute;rio informar o motivo do bloqueio.",'Alerta - Ayllos',"$(\'#motivo_bloqueio_maj\',\'#frmContaCorrente\').focus();hideMsgAguardo();bloqueiaFundo(divRotina);",false);
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "") 
	   exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	if ($operacao == 'ALTERAR') {
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= '		<idseqttl>1</idseqttl>';
		$xml .= "		<flgrenli>".$flgrenli."</flgrenli>";
		$xml .= "		<flgcrdpa>".$flgcrdpa."</flgcrdpa>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "ATENDA", "DESOPE_GRAVA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		// Cria objeto para classe de tratamento de XML
		$xmlObjeto = getObjectXML($xmlResult);
	} else {
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= "		<flgrenli>".$flgrenli."</flgrenli>";
		$xml .= "		<flmajora>".$flmajora."</flmajora>";
		$xml .= "		<dsmotmaj>".$dsmotmaj."</dsmotmaj>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "ATENDA", "DESOPE_GRAVA_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		// Cria objeto para classe de tratamento de XML
		$xmlObjeto = getObjectXML($xmlResult);
	}
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibeErro($msgErro);
	}
	
	echo "showError('inform','Altera&ccedil;&atilde;o salva com sucesso!','Notifica&ccedil;&atilde;o - Ayllos','controlaOperacao(\'\');');";
	
	function exibeErro($msgErro) {
		echo 'showError("error"," '.$msgErro.'","Alerta - Atenda","$(\'#flgrenli\',\'#frmContaCorrente\').focus();hideMsgAguardo();bloqueiaFundo(divRotina);");';
	}
?>
