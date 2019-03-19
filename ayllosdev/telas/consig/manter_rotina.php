<?
/*!
 * FONTE        : manter_rotina.php 
 * CRIAÇÃO      : Leonardo Oliveira - GFT
 * DATA CRIAÇÃO : 01/08/2018
 * OBJETIVO     : Execução de operações da tela CONSIG
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 */
?>

<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$consulta_cddopcao = (isset($_POST['consulta_cddopcao'])) ? $_POST['consulta_cddopcao'] : '' ;
	$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : '' ;
	$indconsignado = (isset($_POST['indconsignado'])) ? $_POST['indconsignado'] : '' ;
	$dtativconsignado = (isset($_POST['dtativconsignado'])) ? $_POST['dtativconsignado'] : '' ;
	$nmextemp = (isset($_POST['nmextemp'])) ? $_POST['nmextemp'] : '' ;
	$tpmodconvenio = (isset($_POST['tpmodconvenio'])) ? $_POST['tpmodconvenio'] : '' ;
	$dtfchfol = (isset($_POST['dtfchfol'])) ? $_POST['dtfchfol'] : '' ;
	$nrdialimiterepasse = (isset($_POST['nrdialimiterepasse'])) ? $_POST['nrdialimiterepasse'] : '' ;
	$indautrepassecc = (isset($_POST['indautrepassecc'])) ? $_POST['indautrepassecc'] : '' ;
	$indinterromper = (isset($_POST['indinterromper'])) ? $_POST['indinterromper'] : '' ;
	$dtinterromper = (isset($_POST['dtinterromper'])) ? $_POST['dtinterromper'] : '' ;
	$dsdemail = (isset($_POST['dsdemail'])) ? $_POST['dsdemail'] : '' ;
	$indalertaemailemp = (isset($_POST['indalertaemailemp'])) ? $_POST['indalertaemailemp'] : '' ;
	$dsdemailconsig = (isset($_POST['dsdemailconsig'])) ? $_POST['dsdemailconsig'] : '' ;
	$indalertaemailconsig = (isset($_POST['indalertaemailconsig'])) ? $_POST['indalertaemailconsig'] : '' ;
	
	$vp_cod = (isset($_POST['vp_cod'])) ? $_POST['vp_cod'] : '' ;
	$vp_de = (isset($_POST['vp_de'])) ? $_POST['vp_de'] : '' ;
	$vp_ate = (isset($_POST['vp_ate'])) ? $_POST['vp_ate'] : '' ;
	$vp_dtEnvio = (isset($_POST['vp_dtEnvio'])) ? $_POST['vp_dtEnvio'] : '' ;
	$vp_dtVencimento = (isset($_POST['vp_dtVencimento'])) ? $_POST['vp_dtVencimento'] : '' ;
	

	if ($cddopcao =='') {// CONSULTA

		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <nmextemp></nmextemp>';
		$xml .= '       <nmresemp></nmresemp>';
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
		$xml .= '       <cddopcao>'.$consulta_cddopcao.'</cddopcao>';
		$xml .= '       <nriniseq>0</nriniseq>';
		$xml .= '       <nrregist>0</nrregist>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';


		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"OBTEM_DADOS_EMP_CONSIGNADO",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");

		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","estadoInicial();");';
			return;
		} //erro
		
		//root/dados/inf
		$inf = $xmlObj->roottag->tags[0]->tags[0]->tags;
		include("form_consig.php");
		return;

	} else if ($cddopcao == 'C' ) {
		echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","estadoInicial();");';
		return;

	} else if ($cddopcao == 'A' ) {// ALTERAR

		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';// cdempres
		$xml .= '       <indconsignado>'.$indconsignado.'</indconsignado>'; // indconsignado
		$xml .= '       <dtativconsignado>'.$dtativconsignado.'</dtativconsignado>'; //dtativconsignado
		$xml .= '       <tpmodconvenio>'.$tpmodconvenio.'</tpmodconvenio>'; //tpmodconvenio
		$xml .= '       <nrdialimiterepasse>'.$nrdialimiterepasse.'</nrdialimiterepasse>'; //nrdialimiterepasse
		$xml .= '       <indautrepassecc>'.$indautrepassecc.'</indautrepassecc>'; //indautrepassecc
		$xml .= '       <indinterromper>'.$indinterromper.'</indinterromper>'; //indinterromper
		$xml .= '       <dsdemailconsig>'.$dsdemailconsig.'</dsdemailconsig>'; //dsdemailconsig
		$xml .= '       <indalertaemailemp>'.$indalertaemailemp.'</indalertaemailemp>'; //indalertaemailemp
		$xml .= '       <indalertaemailconsig>'.$indalertaemailconsig.'</indalertaemailconsig>'; //indalertaemailconsig
		$xml .= '       <dtinterromper>'.$dtinterromper.'</dtinterromper>'; //dtinterromper
		$xml .= '       <dtfchfol>'.$dtfchfol.'</dtfchfol>'; //dtfchfol
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		
		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"ALTERAR_EMPR_CONSIG",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");
		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {

			exibirErro(
				"error",
				$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
				"Alerta - Ayllos",
				"estadoInicial();",
				false);
			
			exit();
		} //erro

		if($xmlObj->roottag->tags[0]){
			echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","estadoInicial();");';
		} else{
			echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","ajustaStatus(1);");';
		}

	} else if ($cddopcao == 'H' ) {// HABILITAR

		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';// cdempres
		$xml .= '       <indconsignado>'.$indconsignado.'</indconsignado>'; // indconsignado
		$xml .= '       <dtativconsignado>'.$glbvars["dtmvtolt"].'</dtativconsignado>'; //dtativconsignado
		$xml .= '       <tpmodconvenio>'.$tpmodconvenio.'</tpmodconvenio>'; //tpmodconvenio
		$xml .= '       <nrdialimiterepasse>'.$nrdialimiterepasse.'</nrdialimiterepasse>'; //nrdialimiterepasse
		$xml .= '       <indautrepassecc>'.$indautrepassecc.'</indautrepassecc>'; //indautrepassecc
		$xml .= '       <indinterromper>'.$indinterromper.'</indinterromper>'; //indinterromper
		$xml .= '       <dsdemailconsig>'.$dsdemailconsig.'</dsdemailconsig>'; //dsdemailconsig
		$xml .= '       <indalertaemailemp>'.$indalertaemailemp.'</indalertaemailemp>'; //indalertaemailemp
		$xml .= '       <indalertaemailconsig>'.$indalertaemailconsig.'</indalertaemailconsig>'; //indalertaemailconsig
		$xml .= '       <dtinterromper>'.$dtinterromper.'</dtinterromper>'; //dtinterromper
		$xml .= '       <dtfchfol>'.$dtfchfol.'</dtfchfol>'; //dtfchfol
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"HABILITAR_EMPR_CONSIG",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");

		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {

			exibirErro(
				"error",
				$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
				"Alerta - Ayllos",
				"estadoInicial();",
				false);
			
			exit();
		} //erro

		if($xmlObj->roottag->tags[0]){
			echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","ajustaStatus(1);");';
		} else{
			echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","ajustaStatus(1);");';
		}

	} else if ($cddopcao == 'D' ) {// DESABILITAR

		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';// cdempres
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"DESABILITAR_EMPR_CONSIG",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");

		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {

			exibirErro(
				"error",
				$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
				"Alerta - Ayllos",
				"estadoInicial();",
				false);
			
			exit();
		} //erro


		if($xmlObj->roottag->tags[0]){
			echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","estadoInicial();");';
		} else{
			echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","ajustaStatus(0);");';
		}
	
	} else if ($cddopcao == 'V' ) {// VALIDAR
	
	} else if ($cddopcao == 'B' ) {// BUSCA

		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <nmextemp></nmextemp>';
		$xml .= '       <nmresemp></nmresemp>';
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
		$xml .= '       <cddopcao>'.$consulta_cddopcao.'</cddopcao>';
		$xml .= '       <nriniseq>0</nriniseq>';
		$xml .= '       <nrregist>0</nrregist>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';


		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"OBTEM_DADOS_EMP_CONSIGNADO",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");

		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","estadoInicial();");';
			return;
		} //erro
		
		if ( strtoupper($xmlObj->roottag->tags[0]->tags[0]->name) == "INF" ) {
			//root/dados/inf
			$inf = $xmlObj->roottag->tags[0]->tags[0]->tags;

			$indconsignado = (getByTagName($inf,'indconsignado'));
			$rowid_emp_consig = (getByTagName($inf,'rowid_emp_consig'));
			$cdempres = (getByTagName($inf,'cdempres'));
			$dtativconsignado = (getByTagName($inf,'dtativconsignado'));

			$js  = 'indconsignado = "'.$indconsignado.'";';
			$js .= 'rowid_emp_consig = "'.$rowid_emp_consig.'";';
			$js .= 'cdempres = "'.$cdempres.'";';
			$js .= 'dtativconsignado = "'.$dtativconsignado.'";';
			echo $js;
			return;				
		} 
		else
		{
			echo 'showError("error","N&atilde;o h&aacute; c&oacute;digo de empresa cadastrado.","Alerta - Ayllos","");';
			return;
		}


	}else if ($cddopcao == 'VPI' ){
		//incluir vencimento parcela CAMPO CODIGO ENVIAR 0 SE FOR INCLUIR
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <idemprconsigparam>'.$vp_cod.'</idemprconsigparam>';// cdempres
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';// 
		$xml .= '       <dtinclpropostade>'.$vp_de.'</dtinclpropostade>';// 
		$xml .= '       <dtinclpropostaate>'.$vp_ate.'</dtinclpropostaate>';// 
		$xml .= '       <dtenvioarquivo>'.$vp_dtEnvio.'</dtenvioarquivo>';// 
		$xml .= '       <dtvencimento>'.$vp_dtVencimento.'</dtvencimento>';// 
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"INC_ALT_VENC_PARCELA",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");
				
		$xmlObj = getObjectXML($xmlResult);
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			$js = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			echo $js;
			return;
		} else {			
			 include('form_vencparc.php');
		}
		
		
	}else if ($cddopcao == 'VPE' ){
		//excluir vencimento parcela
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <idemprconsigparam>'.$vp_cod.'</idemprconsigparam>';
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"EXCLUIR_VENC_PARCELA",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");

		$xmlObj = getObjectXML($xmlResult);
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			$js = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			echo $js;
			return;
		} else {			
			 include('form_vencparc.php');
		}
		
	}else if ($cddopcao == 'VPR' ){
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <idemprconsigparam>'.$vp_cod.'</idemprconsigparam>';// cdempres
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';// 
		$xml .= '       <dtinclpropostade>'.$vp_de.'</dtinclpropostade>';// 
		$xml .= '       <dtinclpropostaate>'.$vp_ate.'</dtinclpropostaate>';// 
		$xml .= '       <dtenvioarquivo>'.$vp_dtEnvio.'</dtenvioarquivo>';// 
		$xml .= '       <dtvencimento>'.$vp_dtVencimento.'</dtvencimento>';// 
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		//replicar vencimento parcela
		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"REPLICAR_VENC_PARCELA",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");

		$xmlObj = getObjectXML($xmlResult);
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			$js = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			echo $js;
			return;
		} else {			
			 include('form_vencparc.php');
		}
		
	}else if ($cddopcao == 'VCC'){
		//Valida se a cooperativa pode ter acesso a consignados
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';// 
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		
		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"VAL_COOPER_CONSIGNADO",
			$glbvars["cdcooper"],
			$glbvars["cdagenci"],
			$glbvars["nrdcaixa"],
			$glbvars["idorigem"],
			$glbvars["cdoperad"],
			"</Root>");
			
		$xmlObj = getObjectXML($xmlResult);

		if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
			exibirErro(
				"error",
				$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
				"Alerta - Ayllos",
				"",
				false);
			$js = "BtnOK.css('display', 'none'); Ccddopcao.desabilitaCampo(); rCooperConsig = '';";
			echo $js;
			exit();
		}else{
			if ($xmlObj->roottag->tags[0]->cdata != 'S'){			
				exibirErro(
				"info",
				"Cooperativa sem acesso ao consignado!",
				"Alerta - Ayllos",
				"",
				false);	
				$js = "BtnOK.css('display', 'none'); Ccddopcao.desabilitaCampo(); rCooperConsig = '".$xmlObj->roottag->tags[0]->cdata."';";
				echo $js;			
				exit();
			}else{
				$js = "rCooperConsig = '".$xmlObj->roottag->tags[0]->cdata."';";
				echo $js;
				return;
			}
			
		}
	}

?>
