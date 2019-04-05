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
	$dtativconsignado = (isset($_POST['dtativconsignado'])) ? $_POST['dtativconsignado'] : date("d/m/Y") ;
	if ($dtativconsignado == '' ){
		$dtativconsignado = date("d/m/Y");
	}
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
	$vencimentos = (isset($_POST['vencimentos'])) ? $_POST['vencimentos'] : '' ;
	

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
		//Enviar informações para FIS
		$vencimentosFis = str_replace("dtinclpropostade", "diaMesDe", $vencimentos);
		$vencimentosFis = str_replace("dtinclpropostaate", "diaMesAte", $vencimentosFis);
		$vencimentosFis = str_replace("dtenvioarquivo", "diaMesEnvio", $vencimentosFis);
		$vencimentosFis = str_replace("dtvencimento", "diaMesVencto", $vencimentosFis);
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<dto>';
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
		$xml .= '       <datainicio>'.$dtativconsignado.'</datainicio>';
		$xml .= '       <indconsignado>'.$indconsignado.'</indconsignado>';
		$xml .= '       <tipoPadrao>'.$tpmodconvenio.'</tipoPadrao>';
		$xml .= '       <idemprconsig>'.$cdempres.'</idemprconsig>';
		$xml .= '       '.$vencimentosFis.'';
		$xml .= '	</dto>';
		$xml .= '</Root>';
		
		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"BUSCA_EMPRESA",
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
			
			exit();
		}else{
			//cham SOA x FIS
			$xml = simplexml_load_string($xmlResult);
			$json = json_encode($xml);		
		}		
		
		if($retSOAxFIS == "ERRO"){
			exibirErro(
				"error",
				$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
				"Alerta - Ayllos",
				"",
				false);
			
			exit();
		}else{
			
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
			$xml .= '       '.$vencimentos.''; //vencimentos
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
					"",
					false);
				
				exit();
			} //erro

			if($xmlObj->roottag->tags[0]){
				echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","estadoInicial();");';
			} else{
				echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","ajustaStatus(1);");';
			}
		}

	} else if ($cddopcao == 'H' ) {// HABILITAR
		//Enviar informações para FIS
		$vencimentosFis = str_replace("dtinclpropostade", "diaMesDe", $vencimentos);
		$vencimentosFis = str_replace("dtinclpropostaate", "diaMesAte", $vencimentosFis);
		$vencimentosFis = str_replace("dtenvioarquivo", "diaMesEnvio", $vencimentosFis);
		$vencimentosFis = str_replace("dtvencimento", "diaMesVencto", $vencimentosFis);		
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<dto>';
		$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
		$xml .= '       <datainicio>'.$dtativconsignado.'</datainicio>';
		$xml .= '       <indconsignado>'.$indconsignado.'</indconsignado>';
		$xml .= '       <tipoPadrao>'.$tpmodconvenio.'</tipoPadrao>';
		$xml .= '       <idemprconsig>'.$cdempres.'</idemprconsig>';
		$xml .= '       '.$vencimentosFis.'';
		$xml .= '	</dto>';
		$xml .= '</Root>';
		
		$xmlResult = mensageria(
			$xml,
			"TELA_CONSIG",
			"BUSCA_EMPRESA",
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
		}else{
			//cham SOA x FIS
		}		
		
		if($retSOAxFIS == "ERRO"){
			exibirErro(
				"error",
				$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
				"Alerta - Ayllos",
				"estadoInicial();",
				false);
			
			exit();
		}else{
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
			$xml .= '       '.$vencimentos.''; //vencimentos
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
				echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","estadoInicial();");';
			} else{
				echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","estadoInicial();");';
			}
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
