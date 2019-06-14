<?php 

	//*************************************************************************************//
	//*** Fonte: contas_incluir_validar.php      										***//
	//*** Autor: Lucas																	***//
	//*** Data : Maio/2012                   Última Alteração: 26/07/2016				***//
	//***																				***//
	//*** Objetivo  : Validar dados para inclusão de contas de transf.					***//
	//***																				***//	 
	//***																				***//	 
	//*** Alterações: 03/07/2013 - Transferencia intercooperativa(Gabriel)				***//	 
	//***																				***//
	//***             31/07/2013 - Correção transferencia intercoop.(Lucas)				***//
	//***																				***//
	//***             24/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)     ***//
	//***																				***//
	//***			  26/07/2016 - Corrigi a forma de recuperacao dos dados do XML.     ***//
	//***						   SD 479874 (Carlos R)									***//
	//*************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) ||
		!isset($_POST["nrctatrf"]) || !isset($_POST["intipdif"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$cddbanco = ( isset($_POST["cddbanco"]) ) ? $_POST["cddbanco"] : null;
    $cdispbif = ( isset($_POST["cdispbif"]) ) ? $_POST["cdispbif"] : null;
	$cdageban = ( isset($_POST["cdageban"]) ) ? $_POST["cdageban"] : null;
	$nrdconta = ( isset($_POST["nrdconta"]) ) ? $_POST["nrdconta"] : null;
	$idseqttl = ( isset($_POST["idseqttl"]) ) ? $_POST["idseqttl"] : null;
	$nrctatrf = ( isset($_POST["nrctatrf"]) ) ? $_POST["nrctatrf"] : null;
	$intipdif = ( isset($_POST["intipdif"]) ) ? $_POST["intipdif"] : null;
	$nrcpfcgc = ( isset($_POST["nrcpfcgc"]) ) ? $_POST["nrcpfcgc"] : null;	
	$nmtitula = ( isset($_POST["nmtitula"]) ) ? $_POST["nmtitula"] : null;
	$inpessoa = ( isset($_POST["inpessoa"]) ) ? $_POST["inpessoa"] : null;
	$intipcta = ( isset($_POST["intipcta"]) ) ? $_POST["intipcta"] : null;
	$nomeform = ( isset($_POST["nomeForm"]) ) ? $_POST["nomeForm"] : null;
			
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetPendentes  = "";
	$xmlGetPendentes .= "<Root>";
	$xmlGetPendentes .= "	<Cabecalho>";
	$xmlGetPendentes .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetPendentes .= "		<Proc>valida-inclusao-conta-transferencia</Proc>";
	$xmlGetPendentes .= "	</Cabecalho>";
	$xmlGetPendentes .= "	<Dados>";
	$xmlGetPendentes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetPendentes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetPendentes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetPendentes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetPendentes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlGetPendentes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetPendentes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetPendentes .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlGetPendentes .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetPendentes .= "		<cddbanco>".$cddbanco."</cddbanco>";
    $xmlGetPendentes .= "		<cdispbif>".$cdispbif."</cdispbif>";
	$xmlGetPendentes .= "		<cdageban>".$cdageban."</cdageban>";
	$xmlGetPendentes .= "		<nrctatrf>".$nrctatrf."</nrctatrf>";
	$xmlGetPendentes .= "		<intipdif>".$intipdif."</intipdif>";
	$xmlGetPendentes .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlGetPendentes .= "		<inpessoa>".$inpessoa."</inpessoa>";
	$xmlGetPendentes .= "		<intipcta>".$intipcta."</intipcta>";
	$xmlGetPendentes .= "		<flvldinc>true</flvldinc>"; //É inclusão de Nova Conta
	$xmlGetPendentes .= "		<nmtitula>".$nmtitula."</nmtitula>";
	$xmlGetPendentes .= "		<insitcta>2</insitcta>";
	$xmlGetPendentes .= "	</Dados>";
	$xmlGetPendentes .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPendentes);

	// Cria objeto para classe de tratamento de XML
	$xmlObjPendentes = getObjectXML($xmlResult);
	
	//Foco no campo de erro
	$nomeCampo = ( isset($xmlObjPendentes->roottag->tags[0]->attributes["NMDCAMPO"]) ) ? $xmlObjPendentes->roottag->tags[0]->attributes["NMDCAMPO"] : '';
	if ( $nomeCampo != '' ) {
		$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeform.'\');bloqueiaFundo(divRotina);';
	} else {
		$mtdErro = 'bloqueiaFundo(divRotina);';
	}

	if ( isset($xmlObjPendentes->roottag->tags[0]->name) && strtoupper($xmlObjPendentes->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error', $xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
	}
	
	//Adquire dados pra exibição
	$registros = ( isset($xmlObjPendentes->roottag->tags[0]->tags) ) ? $xmlObjPendentes->roottag->tags[0]->tags : array();
	
	echo 'hideMsgAguardo();';
	
	if ($intipdif == "1"){
	
		$nmtitula = ( isset($xmlObjPendentes->roottag->tags[0]->attributes["NMTITULA"]) ) ? $xmlObjPendentes->roottag->tags[0]->attributes["NMTITULA"] : '';	
		$dscpfcgc = ( isset($xmlObjPendentes->roottag->tags[0]->attributes["DSCPFCGC"]) ) ? $xmlObjPendentes->roottag->tags[0]->attributes["DSCPFCGC"] : '';	
		$nrcpfcgc = ( isset($xmlObjPendentes->roottag->tags[0]->attributes["NRCPFCGC"]) ) ? $xmlObjPendentes->roottag->tags[0]->attributes["NRCPFCGC"] : '';	
		$inpessoa = ( isset($xmlObjPendentes->roottag->tags[0]->attributes["INPESSOA"]) ) ? $xmlObjPendentes->roottag->tags[0]->attributes["INPESSOA"] : '';	
			
	} 
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	if ($intipdif != "1") {	
?>			

	$("#divConteudoOpcao").html('');
		
	strHTML = '';		 
	strHTML += '<div id="divSenhaCnt" style="display: block;">';
	strHTML += '	<br /><br /><br /><br /><br /><br />';
	strHTML += '	<form action="" method="post" name="frmSnhIncluirConta" id="frmSnhIncluirConta">';
	strHTML += '		<input type="hidden" name="nrdconta" id="nrdconta" value = "<? echo $nrdconta ?>" />';
	strHTML += '		<input type="hidden" name="idseqttl" id="idseqttl" value = "<? echo $idseqttl ?>" />';
	strHTML += '		<input type="hidden" name="dscpfcgc" id="dscpfcgc" value = "<? echo $dscpfcgc ?>" />';
	strHTML += '		<input type="hidden" name="nmtitula" id="nmtitula" value = "<? echo $nmtitula ?>" />';
	strHTML += '		<input type="hidden" name="cddbanco" id="cddbanco" value = "<? echo $cddbanco ?>" />';
	strHTML += '		<input type="hidden" name="cdageban" id="cdageban" value = "<? echo $cdageban ?>" />';
	strHTML += '		<input type="hidden" name="intipdif" id="intipdif" value = "<? echo $intipdif ?>" />';
	strHTML += '		<input type="hidden" name="nrctatrf" id="nrctatrf" value = "<? echo $nrctatrf ?>" />';
	strHTML += '		<input type="hidden" name="inpessoa" id="inpessoa" value = "<? echo $inpessoa ?>" />';
	strHTML += '		<input type="hidden" name="nrcpfcgc" id="nrcpfcgc" value = "<? echo $nrcpfcgc ?>" />';
	strHTML += '		<input type="hidden" name="intipcta" id="intipcta" value = "<? echo $intipcta ?>" />';
	strHTML += '		<input type="hidden" name="cdispbif" id="cdispbif" value = "<? echo $cdispbif ?>" />';
	strHTML += '		<label for="cdsnhnew"><? echo utf8ToHtml('Senha:') ?></label>';
	strHTML += '		<input name="cdsnhnew" class = "campo" id="cdsnhnew" type="password"/>';
	strHTML += '		<br />';
	strHTML += '		<label for="cdsnhrep"><? echo utf8ToHtml('Confirma Senha:') ?></label>';
	strHTML += '		<input name="cdsnhrep" class = "campo" id="cdsnhrep"  type="password"/>';
	strHTML += '	</form>';
	strHTML += '	<div id="divBotoes">';
	strHTML += '		<input type="image" id = "btContinuar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="VerificaSnhIncCont(); return false;" />';
	strHTML += '		<input type="image" id = "btVoltar" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="InclusaoContas(); return false;" />';
	strHTML += '	</div>';
	strHTML += '</div>';
	$("#divConteudoOpcao").html(strHTML);
	
	nomeForm = 'frmSnhIncluirConta';
	
	$('#'+nomeForm).addClass('formulario');

	var Lcdsnhnew = $('label[for="cdsnhnew"]','#'+nomeForm);
	var Lcdsnhrep = $('label[for="cdsnhrep"]','#'+nomeForm);
	
	var Ccdsnhnew = $('#cdsnhnew','#'+nomeForm);
	var Ccdsnhrep = $('#cdsnhrep','#'+nomeForm);
	
	Lcdsnhnew.addClass('rotulo').css('width','200px');
	Lcdsnhrep.addClass('rotulo').css('width','200px');
	         
	Ccdsnhnew.css({'width':'108px'});
    Ccdsnhrep.css({'width':'108px'});
	
	Ccdsnhnew.habilitaCampo();
    Ccdsnhrep.habilitaCampo();
	$('#divBotoes','#divSenhaCnt').css({'margin':'4px 0 0 28px','clear':'both'});
	
	//Foca no próximo campo caso pressine ENTER 
	Ccdsnhnew.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			Ccdsnhrep.focus(); 
			return false; 
		}		
	});
	
	Ccdsnhrep.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			$('#btContinuar','#frmSnhIncluirConta').focus(); 
			return false; 
		}		
	});
	
	$("#cdsnhrep","#frmSnhIncluirConta").setMask("INTEGER","zzzzzzzz","","");
	$("#cdsnhnew","#frmSnhIncluirConta").setMask("INTEGER","zzzzzzzz","",""); 
	$('#cdsnhnew','#frmSnhIncluirConta').focus();
	
	<?php } else { ?>
	
	strHTML = '';	
	strHTML += '<form id="InclDados" name="InclDados" style="display: none;">';
	strHTML += '	<input type="hidden" name="nrdconta" id="nrdconta" value = "<? echo $nrdconta ?>" />';
	strHTML += '	<input type="hidden" name="idseqttl" id="idseqttl" value = "<? echo $idseqttl ?>" />';
	strHTML += '	<input type="hidden" name="dscpfcgc" id="dscpfcgc" value = "<? echo $dscpfcgc ?>" />';
	strHTML += '	<input type="hidden" name="nmtitula" id="nmtitula" value = "<? echo $nmtitula ?>" />';
	strHTML += '	<input type="hidden" name="cdageban" id="cdageban" value = "<? echo $cdageban ?>" />';
	strHTML += '	<input type="hidden" name="intipdif" id="intipdif" value = "<? echo $intipdif ?>" />';
	strHTML += '	<input type="hidden" name="nrctatrf" id="nrctatrf" value = "<? echo $nrctatrf ?>" />';
	strHTML += '	<input type="hidden" name="inpessoa" id="inpessoa" value = "<? echo $inpessoa ?>" />';
	strHTML += '	<input type="hidden" name="nrcpfcgc" id="nrcpfcgc" value = "<? echo $nrcpfcgc ?>" />';
	strHTML += '	<input type="hidden" name="intipcta" id="intipcta" value = "<? echo $intipcta ?>" />';
    strHTML += '    <input type="hidden" name="cdispbif" id="cdispbif" value = "<? echo $cdispbif ?>" />';
	
	strHTML += '</form>';
	
	$("#divConteudoOpcao").append(strHTML);
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	<?php echo "confirmaIncluirConta ('1' , 'frmInclCoop');";  ?>
	
	<?php } ?>	