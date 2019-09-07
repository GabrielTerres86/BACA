<?
/*!
 * FONTE        : carrega_dados_proposta_linha_credito.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 28/09/2016
 * OBJETIVO     : Carrega os dados da proposta a partir do campo Linha de Credito
 * --------------
 * ALTERAÇÕES   : 25/04/2017 - Incluido retorno da variável inobriga
 *                22/05/2019 - Retirada do etapa Rating mantendo apenas para coop Ailos P450 (Luiz Otávio Olinger Momm - AMCOM).
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
	

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdacesso>HABILITA_RATING_NOVO</cdacesso>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_CRAPPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjPRM = getObjectXML($xmlResult);

	$habrat = 'N';
	if (strtoupper($xmlObjPRM->roottag->tags[0]->name) == "ERRO") {
		$habrat = 'N';
	} else {
		$habrat = $xmlObjPRM->roottag->tags[0]->tags;
		$habrat = getByTagName($habrat[0]->tags, 'PR_DSVLRPRM');
	}

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"$('#cdlcremp').val('');$('#cdlcremp').val('');$('#cdlcremp').attr('aux','');",false);
	}else{
		echo "$('#nivrisco').val('".$xmlObjeto->roottag->tags[0]->attributes['DSNIVRIS']."');";
		// ********************************************
		// AMCOM - Retira Etapa Rating exceto para Ailos (coop 3)
		if ($glbvars["cdcooper"] == 3 || $habrat == 'N') {
			echo "inobriga = '".$xmlObjeto->roottag->tags[0]->attributes['INOBRIGA']."';";
		} else {
			echo "inobriga = 'S';";
		}
		// ********************************************
		echo "aux_inobriga_rating = '".$xmlObjeto->roottag->tags[0]->attributes['INOBRIGA']."';"; //prj - 438 - rating - bruno
	}
?>