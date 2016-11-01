<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013 
 * OBJETIVO     : Rotina para manter as operações da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 01/10/2013 - Alterado para setar focus no cCdorigem (Lucas R.)
 *                12/09/2014 - Ajuste na verificação de permissão por tipo de operação (Jaison)
 *                31/08/2015 - Ajustado os campos de Assessoria e Motivo CIN (Douglas - Melhoria 12)
 * -------------- 
 */

    session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : ""; 
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0 ; 
	$nrctremp = (isset($_POST["nrctremp"])) ? $_POST["nrctremp"] : 0 ; 
	$cdorigem = (isset($_POST["cdorigem"])) ? $_POST["cdorigem"] : 0 ; 
	$flgjudic = $_POST["flgjudic"];
	$flextjud = $_POST["flextjud"];
	$flgehvip = $_POST["flgehvip"];
	$dtenvcbr = $_POST["dtenvcbr"];
	$cdassess = (isset($_POST["cdassess"])) ? $_POST["cdassess"] : 0 ; 
	$cdmotcin = (isset($_POST["cdmotcin"])) ? $_POST["cdmotcin"] : 0 ; 
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$operacao)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xmlContrato  = "";
	$xmlContrato .= "<Root>";
	$xmlContrato .= "	<Cabecalho>";
	$xmlContrato .= "		<Bo>b1wgen0170.p</Bo>";
	$xmlContrato .= "		<Proc>valida-cadcyb</Proc>";
	$xmlContrato .= "	</Cabecalho>";
	$xmlContrato .= "	<Dados>";
	$xmlContrato .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlContrato .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlContrato .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlContrato .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlContrato .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlContrato .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlContrato .= "		<idseqttl>1</idseqttl>";	
	$xmlContrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlContrato .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xmlContrato .= "		<cdorigem>".$cdorigem."</cdorigem>";
	$xmlContrato .= "		<cddopcao>".$operacao."</cddopcao>";
	$xmlContrato .= "	</Dados>";
	$xmlContrato .= "</Root>";

	$xmlResultContrato = getDataXML($xmlContrato);
	$xmlObjetoContrato = getObjectXML($xmlResultContrato);		
	
	if (strtoupper($xmlObjetoContrato->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro = $xmlObjetoContrato->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($operacao == "I") {
			exibirErro("error",$msgErro,"Alerta - Ayllos","limparCamposCabecalho();",false);
		} else {
			exibirErro("error",$msgErro,"Alerta - Ayllos","estadoInicial();",false);
		}
	}
	
	if ($operacao == "I") {
		echo "criaObjetoAssociado('" . $cdorigem 
                              ."', '". $nrdconta 
                              ."', '". $nrctremp 
                              ."', '". $flgjudic 
                              ."', '". $flextjud 
                              ."', '". $flgehvip 
                              ."', '". $dtenvcbr
                              ."', '". $cdassess 
                              ."', '".  $cdmotcin ."');";
		echo "carregaTabela();";
		echo "formataTabela();";
		echo "zebradoLinhaTabela($('#tbCadcyb > tbody > tr'));";
	}

	if ($operacao == "A" || $operacao == "E" ) {
		$judicial = $xmlObjetoContrato->roottag->tags[0]->attributes["FLGJUDIC"];
		$extjudic = $xmlObjetoContrato->roottag->tags[0]->attributes["FLEXTJUD"];
		$ehvip    = $xmlObjetoContrato->roottag->tags[0]->attributes["FLGEHVIP"];
		$flgmsger = $xmlObjetoContrato->roottag->tags[0]->attributes["FLGMSGER"];
		$dtenvcbr = $xmlObjetoContrato->roottag->tags[0]->attributes["DTENVCBR"];
		$cdassess = $xmlObjetoContrato->roottag->tags[0]->attributes["CDASSESS"];
		$nmassess = $xmlObjetoContrato->roottag->tags[0]->attributes["NMASSESS"];
		$cdmotcin = $xmlObjetoContrato->roottag->tags[0]->attributes["CDMOTCIN"];
		$dsmotcin = $xmlObjetoContrato->roottag->tags[0]->attributes["DSMOTCIN"];
		
		if ($judicial == "SIM") {
			echo "$('#flgjudic','#frmCab').prop('checked',true);";			
		} else {
			 echo "$('#flgjudic','#frmCab').prop('checked',false);";
		}
		
		if ($extjudic == "SIM") {
			echo "$('#flextjud','#frmCab').prop('checked',true);";
		} else {
			 echo "$('#flextjud','#frmCab').prop('checked',false);";
		}
		
		if ($ehvip == "SIM") {
			echo "$('#flgehvip','#frmCab').prop('checked',true);";
		} else {
			echo "$('#flgehvip','#frmCab').prop('checked',false);";
		}
		
		echo "$('#dtenvcbr','#frmCab').val('".$dtenvcbr."');";
		if($cdassess != "0"){
			echo "$('#cdassessoria','#frmCab').val('".$cdassess."');";
			echo "$('#nmassessoria','#frmCab').val('".$nmassess."');";
		}
		if($cdmotcin != "0") {
			echo "$('#cdmotivocin','#frmCab').val('".$cdmotcin."');";
			echo "$('#dsmotivocin','#frmCab').val('".$dsmotcin."');";
		}

		if ($operacao == "E") {
			if ($flgmsger == "yes") {
				echo "showConfirmacao('Contrato j&aacute; enviado para cobran&ccedil;a, confirma exslusão do registro?','Confirma&ccedil;&atilde;o - Ayllos','excluirCrapcyc(\'".$flgmsger."\');','','sim.gif','nao.gif');";
			}else{
				echo "$('#btExclusao','#divBotoes').focus();";
			}
		}
	}
?>