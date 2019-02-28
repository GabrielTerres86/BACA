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
			echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","estadoInicial();");';
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
			echo 'showError("inform","'.$xmlObj->roottag->tags[0]->cdata.'","Alerta - Ayllos","estadoInicial();");';
		} else{
			echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","estadoInicial();");';
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
			echo 'showError("inform","Opera&ccedil;&atilde;o efetuada com sucesso!","Alerta - Ayllos","estadoInicial();");';
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


	}

?>
