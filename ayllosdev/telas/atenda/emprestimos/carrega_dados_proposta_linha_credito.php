<?
/*!
 * FONTE        : carrega_dados_proposta_linha_credito.php
 * CRIA��O      : James Prust J�nior
 * DATA CRIA��O : 28/09/2016
 * OBJETIVO     : Carrega os dados da proposta a partir do campo Linha de Credito
 * --------------
 * ALTERA��ES   : 25/04/2017 - Incluido retorno da vari�vel inobriga
 * --------------
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : ''; 
	$cdfinemp = (isset($_POST['cdfinemp'])) ? $_POST['cdfinemp'] : '';
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '';
  $dsctrliq = (isset($_POST['dsctrliq'])) ? $_POST['dsctrliq'] : '';
	
	$xml  = "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>carrega_dados_proposta_linha_credito</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";		
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdfinemp>".$cdfinemp."</cdfinemp>";
	$xml .= "		<cdlcremp>".$cdlcremp."</cdlcremp>";
  $xml .= "		<dsctrliq>".$dsctrliq."</dsctrliq>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"$('#cdlcremp').val('');$('#cdlcremp').val('');$('#cdlcremp').attr('aux','');",false);
	}else{
		echo "$('#nivrisco').val('".$xmlObjeto->roottag->tags[0]->attributes['DSNIVRIS']."');";
		echo "inobriga = '".$xmlObjeto->roottag->tags[0]->attributes['INOBRIGA']."';";
	}
?>