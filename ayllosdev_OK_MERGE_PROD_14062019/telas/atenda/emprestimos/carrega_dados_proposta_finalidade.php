<?
/*!
 * FONTE        : carrega_dados_proposta_finalidade.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 31/07/2014
 * OBJETIVO     : Carrega os dados da proposta a partir do campo Finalidade
 * --------------
 * ALTERAÇÕES   : 26/06/2015 - Incluir parametros na chamada da procedure (James)
                      17/06/2016 - M181 - Alterar o CDAGENCI para          
                             passar o CDPACTRA (Rafael Maciel - RKAM) 
 * --------------
 * 
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : ''; 
	$tpemprst = (isset($_POST['tpemprst'])) ? $_POST['tpemprst'] : '';
	$cdfinemp = (isset($_POST['cdfinemp'])) ? $_POST['cdfinemp'] : '';
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '';
	$dsctrliq = (isset($_POST['dsctrliq'])) ? $_POST['dsctrliq'] : '';
	
	$xml  = "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>carrega_dados_proposta_finalidade</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";	
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<tpemprst>".$tpemprst."</tpemprst>";
	$xml .= "		<cdfinemp>".$cdfinemp."</cdfinemp>";
	$xml .= "		<cdlcremp>".$cdlcremp."</cdlcremp>";
	$xml .= "		<dsctrliq>".$dsctrliq."</dsctrliq>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	
	echo "aDadosPropostaFinalidade = new Array();";
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"$('#cdfinemp').val('');$('#dsfinemp').val('');$('#cdfinemp').attr('aux','');",false);
	}else{
		$proposta = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		echo "aDadosPropostaFinalidade['flgcescr'] = '".((getByTagName($proposta,'flgcescr') == 'yes') ? true : false)."';";
		echo "arrayProposta['flgcescr']			   = aDadosPropostaFinalidade['flgcescr'];";
		echo "aDadosPropostaFinalidade['dsnivris'] = '".getByTagName($proposta,'dsnivris')."';";
		echo "aDadosPropostaFinalidade['dtdpagto'] = '".getByTagName($proposta,'dtdpagto')."';";
		echo "aDadosPropostaFinalidade['nrinfcad'] = '".getByTagName($proposta,'nrinfcad')."';";
		echo "aDadosPropostaFinalidade['dsinfcad'] = '".getByTagName($proposta,'dsinfcad')."';";
		echo "aDadosPropostaFinalidade['nrgarope'] = '".getByTagName($proposta,'nrgarope')."';";
		echo "aDadosPropostaFinalidade['dsgarope'] = '".getByTagName($proposta,'dsgarope')."';";
		echo "aDadosPropostaFinalidade['nrperger'] = '".getByTagName($proposta,'nrperger')."';";
		echo "aDadosPropostaFinalidade['dsperger'] = '".getByTagName($proposta,'dsperger')."';";
		echo "aDadosPropostaFinalidade['nrliquid'] = '".getByTagName($proposta,'nrliquid')."';";
		echo "aDadosPropostaFinalidade['dsliquid'] = '".getByTagName($proposta,'dsliquid')."';";
		echo "aDadosPropostaFinalidade['nrpatlvr'] = '".getByTagName($proposta,'nrpatlvr')."';";		
		echo "aDadosPropostaFinalidade['dspatlvr'] = '".getByTagName($proposta,'dspatlvr')."';";		
		echo "$('#nivrisco').val('".getByTagName($proposta,'dsnivris')."');";
		
		// Somente vamos carregar a data de pagamento, caso for diferente que vazio
		if (getByTagName($proposta,'dtdpagto') != ""){
			echo "$('#dtdpagto').val('".getByTagName($proposta,'dtdpagto')."');";
		}
	}
?>