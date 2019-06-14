<?
/*!
 * FONTE        : habilitar.php
 * CRIAÇÃO      : David
 * DATA CRIAÇÃO : 07/07/2011 
 * OBJETIVO     : Script para carregar opção Habilitar 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [05/05/2011] Rodolpho     (DB1) : Adaptações para o formulário genérico de avalistas
 * 002: [07/07/2011] Gabriel      (DB1) : Alterado para layout padrão
 * 003: [26/08/2015] James				: Remover o form da impressao.
 */
?>

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';	
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);	
	}			
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);

	$nrdconta = $_POST["nrdconta"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	
	// Monta o xml de requisição
	$xmlGetHabilita  = "";
	$xmlGetHabilita .= "<Root>";
	$xmlGetHabilita .= "	<Cabecalho>";
	$xmlGetHabilita .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetHabilita .= "		<Proc>carrega_dados_habilitacao</Proc>";
	$xmlGetHabilita .= "	</Cabecalho>";
	$xmlGetHabilita .= "	<Dados>";
	$xmlGetHabilita .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetHabilita .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetHabilita .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xmlGetHabilita .= "	</Dados>";
	$xmlGetHabilita .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetHabilita);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjHabilita = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjHabilita->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjHabilita->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro);
	} 
	
	$dados = $xmlObjHabilita->roottag->tags[0]->tags[0]->tags;
	
	$flgalter = getByTagName($dados,"FLGALTER");
    $nmprimtl = getByTagName($dados,"NMPRIMTL");
	$nrcpfcgc = getByTagName($dados,"NRCPFCGC");
	$vllimglb = getByTagName($dados,"VLLIMGLB");
	$flgativo = getByTagName($dados,"FLGATIVO");
	$nrcpfpri = getByTagName($dados,"NRCPFPRI");
	$nmpespri = getByTagName($dados,"NMPESPRI");
	$dtnaspri = getByTagName($dados,"DTNASPRI");
	$flgrepr1 = getByTagName($dados,"FLGREPR1");	
	$nrcpfseg = getByTagName($dados,"NRCPFSEG");
	$nmpesseg = getByTagName($dados,"NMPESSEG");
	$dtnasseg = getByTagName($dados,"DTNASSEG");
	$flgrepr2 = getByTagName($dados,"FLGREPR2");
	$nrcpfter = getByTagName($dados,"NRCPFTER");
	$nmpester = getByTagName($dados,"NMPESTER");	
	$dtnaster = getByTagName($dados,"DTNASTER");
	$flgrepr3 = getByTagName($dados,"FLGREPR3");
	$nrctrcrd = getByTagName($dados,"NRCTRCRD");
	$nrctaav1 = getByTagName($dados,"NRCTAAV1");
	$nrctaav2 = getByTagName($dados,"NRCTAAV2");	
	
	if ($nrctrcrd == "0") {
		$nrctaav1 = "0";
		$nmdaval1 = "";
		$nrcpfav1 = "0";
		$tpdocav1 = "";
		$dsdocav1 = "";
		$nmdcjav1 = "";
		$cpfcjav1 = "0";
		$tdccjav1 = "";
		$doccjav1 = "";
		$ende1av1 = "";
		$ende2av1 = "";
		$nrcepav1 = "0";
		$nmcidav1 = "";
		$cdufava1 = "";
		$nrfonav1 = "";
		$emailav1 = "";
		$nrctaav2 = "0";
		$nmdaval2 = "";
		$nrcpfav2 = "0";
		$tpdocav2 = "";
		$dsdocav2 = "";
		$nmdcjav2 = "";
		$cpfcjav2 = "0";
		$tdccjav2 = "";
		$doccjav2 = "";
		$ende1av2 = "";
		$ende2av2 = "";
		$nrcepav2 = "0";
		$nmcidav2 = "";
		$cdufava2 = "";
		$nrfonav2 = "";
		$emailav2 = "";
	} else {
		// Monta o xml de requisição
		$xmlGetAvais = "";
		$xmlGetAvais .= "<Root>";
		$xmlGetAvais .= "	<Cabecalho>";
		$xmlGetAvais .= "		<Bo>b1wgen0028.p</Bo>";
		$xmlGetAvais .= "		<Proc>carrega_dados_avais</Proc>";
		$xmlGetAvais .= "	</Cabecalho>";
		$xmlGetAvais .= "	<Dados>";
		$xmlGetAvais .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlGetAvais .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlGetAvais .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlGetAvais .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetAvais .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlGetAvais .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlGetAvais .= "		<nrdconta>".$nrdconta."</nrdconta>";	
		$xmlGetAvais .= "		<idseqttl>1</idseqttl>";
		$xmlGetAvais .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlGetAvais .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$xmlGetAvais .= "	</Dados>";
		$xmlGetAvais .= "</Root>";

		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetAvais);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjAvais = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjAvais->roottag->tags[0]->name) == "ERRO") {
			exibirErro('error',$xmlObjAvais->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro);
		}

		$avais 		= $xmlObjAvais->roottag->tags[0]->tags;
		$registros 	= $avais;
		$qtAvais 	= count($avais);
		
		if ($qtAvais > 0) {
			$nrctaav1 = getByTagName($avais[0]->tags,"NRCTAAVA");
			$nmdaval1 = getByTagName($avais[0]->tags,"NMDAVALI");
			$nrcpfav1 = getByTagName($avais[0]->tags,"NRCPFCGC");
			$tpdocav1 = getByTagName($avais[0]->tags,"TPDOCAVA");
			$dsdocav1 = getByTagName($avais[0]->tags,"NRDOCAVA");
			$nmdcjav1 = getByTagName($avais[0]->tags,"NMCONJUG");
			$cpfcjav1 = getByTagName($avais[0]->tags,"NRCPFCJG");
			$tdccjav1 = getByTagName($avais[0]->tags,"TPDOCCJG");
			$doccjav1 = getByTagName($avais[0]->tags,"NRDOCCJG");
			$ende1av1 = getByTagName($avais[0]->tags,"DSENDRE1");
			$ende2av1 = getByTagName($avais[0]->tags,"DSENDRE2");
			$nrcepav1 = getByTagName($avais[0]->tags,"NRCEPEND");
			$nmcidav1 = getByTagName($avais[0]->tags,"NMCIDADE");
			$cdufava1 = getByTagName($avais[0]->tags,"CDUFRESD");
			$nrfonav1 = getByTagName($avais[0]->tags,"NRFONRES");
			$emailav1 = getByTagName($avais[0]->tags,"DSDEMAIL");
		} else {
			$nrctaav1 = "0";
			$nmdaval1 = "";
			$nrcpfav1 = "0";
			$tpdocav1 = "";
			$dsdocav1 = "";
			$nmdcjav1 = "";
			$cpfcjav1 = "0";
			$tdccjav1 = "";
			$doccjav1 = "";
			$ende1av1 = "";
			$ende2av1 = "";
			$nrcepav1 = "0";
			$nmcidav1 = "";
			$cdufava1 = "";
			$nrfonav1 = "";
			$emailav1 = "";
		}
		
		if ($qtAvais > 1) {
			$nrctaav2 = getByTagName($avais[1]->tags,"NRCTAAVA");
			$nmdaval2 = getByTagName($avais[1]->tags,"NMDAVALI");
			$nrcpfav2 = getByTagName($avais[1]->tags,"NRCPFCGC");
			$tpdocav2 = getByTagName($avais[1]->tags,"TPDOCAVA");
			$dsdocav2 = getByTagName($avais[1]->tags,"NRDOCAVA");
			$nmdcjav2 = getByTagName($avais[1]->tags,"NMCONJUG");
			$cpfcjav2 = getByTagName($avais[1]->tags,"NRCPFCJG");
			$tdccjav2 = getByTagName($avais[1]->tags,"TPDOCCJG");
			$doccjav2 = getByTagName($avais[1]->tags,"NRDOCCJG");
			$ende1av2 = getByTagName($avais[1]->tags,"DSENDRE1");
			$ende2av2 = getByTagName($avais[1]->tags,"DSENDRE2");
			$nrcepav2 = getByTagName($avais[1]->tags,"NRCEPEND");
			$nmcidav2 = getByTagName($avais[1]->tags,"NMCIDADE");
			$cdufava2 = getByTagName($avais[1]->tags,"CDUFRESD");
			$nrfonav2 = getByTagName($avais[1]->tags,"NRFONRES");
			$emailav2 = getByTagName($avais[1]->tags,"DSDEMAIL");
		} else {
			$nrctaav2 = "0";
			$nmdaval2 = "";
			$nrcpfav2 = "0";
			$tpdocav2 = "";
			$dsdocav2 = "";
			$nmdcjav2 = "";
			$cpfcjav2 = "0";
			$tdccjav2 = "";
			$doccjav2 = "";
			$ende1av2 = "";
			$ende2av2 = "";
			$nrcepav2 = "0";
			$nmcidav2 = "";
			$cdufava2 = "";
			$nrfonav2 = "";
			$emailav2 = "";
		}
	}	
?>
<?/**/?>
<form action="" name="frmHabilitaCartao" id="frmHabilitaCartao" method="post" onSubmit="return false;">
	<div id="divDadosHabilita">							
		<fieldset>
			<legend>Habilitar</legend>
			
			<label for="nmprimtl"><? echo utf8ToHtml('Razão Social:') ?></label>
			<input name="nmprimtl" type="text" id="nmprimtl" value="<? echo $nmprimtl; ?>" class="campoTelaSemBorda" disabled />
			<br />
		
			<label for="nrcpfcgc"><? echo utf8ToHtml('CNPJ:') ?></label>
			<input name="nrcpfcgc" type="text" id="nrcpfcgc" value="<? echo formataNumericos("99.999.999/9999-99",$nrcpfcgc,"./-"); ?>" class="campoTelaSemBorda" disabled />
			<br />
		
			<label for="flgativo"><? echo utf8ToHtml('Ativo:') ?></label>
			<select name="flgativo" class="campo" id="flgativo">
				<option value="yes"<? if (strtolower($flgativo) == "yes") echo " selected"; ?> >SIM</option>
				<option value="no"<? if (strtolower($flgativo) == "no") echo " selected"; ?>   >NAO</option>
			</select>
		
			<label for="vllimglb"><? echo utf8ToHtml('Limite Cartão Empresarial:') ?></label>
			<input name="vllimglb" type="text" id="vllimglb" value="<? echo number_format(str_replace(",",".",$vllimglb),2,",","."); ?>" class="campo" />
			<br />
				
			<label for="nrcpfpri"><? echo utf8ToHtml('CPF:') ?></label>
			<input name="nrcpfpri" type="text" id="nrcpfpri" value="<? echo formataNumericos("999.999.999-99",$nrcpfpri,".-"); ?>" class="campo" />
			<br />
		
			<label for="nmpespri"><? echo utf8ToHtml('Representante:') ?></label>
			<input name="nmpespri" type="text" id="nmpespri" value="<? echo $nmpespri; ?>" <? if ($flgrepr1 == "yes") { echo 'class="campoTelaSemBorda" disabled'; } else { echo 'class="campo"'; } ?> />
			
			<label for="dtnaspri"><? echo utf8ToHtml('Data Nascimento:') ?></label>
			<input name="dtnaspri" type="text" id="dtnaspri" value="<? echo $dtnaspri; ?>" <? if ($flgrepr1 == "yes") { echo 'class="campoTelaSemBorda" disabled'; } else { echo 'class="campo"'; } ?> />
			<br />
		
			<label for="nrcpfseg"><? echo utf8ToHtml('CPF:') ?></label>
			<input name="nrcpfseg" type="text" id="nrcpfseg" style="width: 90px; text-align: right;" value="<? echo formataNumericos("999.999.999-99",$nrcpfseg,".-"); ?>" class="campo">
			<br />
		
			<label for="nmpesseg"><? echo utf8ToHtml('Representante:') ?></label>
			<input name="nmpesseg" type="text" id="nmpesseg" style="width: 235px;" value="<? echo $nmpesseg; ?>" <? if ($flgrepr2 == "yes") { echo 'class="campoTelaSemBorda" disabled'; } else { echo 'class="campo"'; } ?>>
			
			<label for="dtnasseg"><? echo utf8ToHtml('Data Nascimento:') ?></label>
			<input name="dtnasseg" type="text" id="dtnasseg" style="width: 70px;" value="<? echo $dtnasseg; ?>" <? if ($flgrepr2 == "yes") { echo 'class="campoTelaSemBorda" disabled'; } else { echo 'class="campo"'; } ?>>
			<br />
		
			<label for="nrcpfter"><? echo utf8ToHtml('CPF:') ?></label>
			<input name="nrcpfter" type="text" id="nrcpfter" style="width: 90px; text-align: right;" value="<? echo formataNumericos("999.999.999-99",$nrcpfter,".-"); ?>" class="campo">
			<br />
		
			<label for="nmpester"><? echo utf8ToHtml('Representante:') ?></label>
			<input name="nmpester" type="text" id="nmpester" style="width: 235px;" value="<? echo $nmpester; ?>" <? if ($flgrepr3 == "yes") { echo 'class="campoTelaSemBorda" disabled'; } else { echo 'class="campo"'; } ?>>
			
			<label for="dtnaster"><? echo utf8ToHtml('Data Nascimento:') ?></label>
			<input name="dtnaster" type="text" id="dtnaster" style="width: 70px;" value="<? echo $dtnaster; ?>" <? if ($flgrepr3 == "yes") { echo 'class="campoTelaSemBorda" disabled'; } else { echo 'class="campo"'; } ?>>
			<br />
			
		</fieldset>
		
		<div id="divBotoes" >
			<input type="image" name="btnVoltarHabilita" id="btnVoltarHabilita" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="validarDadosHabilita();return false;">
		</div>
		
	</div>
	
	<div id="divDadosAvalistas" class="condensado" >
		<? 
			// ALTERAÇÃO 001: Substituido formulário antigo pelo include				
			include('../../../includes/avalistas/form_avalista.php'); 
		?>
		<div id="divBotoes">
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="mostraDivDadosHabilita();return false;">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar a habilita&ccedil;&atilde;o de cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','voltaDiv(0,1,4);metodoBlock()','metodoBlock()','sim.gif','nao.gif');return false;">
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(5);return false;">
		</div>			
	</div>
		
</form>
<script type="text/javascript">
	controlaLayout('frmHabilitaCartao');
	
	cpfpriat = $("#nrcpfpri","#frmHabilitaCartao").val();
	cpfsegat = $("#nrcpfseg","#frmHabilitaCartao").val();
	cpfterat = $("#nrcpfter","#frmHabilitaCartao").val();

	$("#flgativo","#frmHabilitaCartao").unbind("change").bind("change",function() {	
		if ($(this).val() == "yes") {
			$("#vllimglb","#frmHabilitaCartao").removeProp("disabled");
		} else {
			$("#vllimglb","#frmHabilitaCartao").val("0,00").prop("disabled",true);
		}
	});
	$("#flgativo","#frmHabilitaCartao").trigger("change");

	$("#vllimglb","#frmHabilitaCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");

	$("#nrcpfpri","#frmHabilitaCartao").unbind("blur").unbind("keydown").unbind("keyup");
	$("#nrcpfpri","#frmHabilitaCartao").bind("blur",function() {
		$(this).setMaskOnBlur("INTEGER","999.999.999-99","","divRotina");
		
		if ($(this).val() != "" && $(this).val() != "000.000.000-00") {
			if ($(this).val() == cpfpriat) {
				return true;
			}
			
			if (!validaCpfCnpj(retiraCaracteres($(this).val(),"0123456789",true),1)) {
				showError("error","CPF inv&aacute;lido.","Alerta - Aimaro","$('#nrcpfpri','#frmHabilitaCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
				return false;
			}
			
			carregarRepresentante("H",1,$(this).val());
		} else {
			$("#nmpespri","#frmHabilitaCartao").val("").prop("disabled",true).attr("class","campoTelaSemBorda");
			$("#dtnaspri","#frmHabilitaCartao").val("").prop("disabled",true).attr("class","campoTelaSemBorda");
		}	
		
		return true;
	});
	$("#nrcpfpri","#frmHabilitaCartao").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("INTEGER","999.999.999-99","",e); });
	$("#nrcpfpri","#frmHabilitaCartao").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("INTEGER","999.999.999-99","",e); });
	$("#nmpespri","#frmHabilitaCartao").setMask("STRING",40,charPermitido(),"");
	$("#dtnaspri","#frmHabilitaCartao").setMask("DATE","","","divRotina");

	$("#nrcpfseg","#frmHabilitaCartao").unbind("blur").unbind("keydown").unbind("keyup");
	$("#nrcpfseg","#frmHabilitaCartao").bind("blur",function() {
		$(this).setMaskOnBlur("INTEGER","999.999.999-99","","divRotina");
		
		if ($(this).val() != "" && $(this).val() != "000.000.000-00") {
			if ($(this).val() == cpfsegat) {
				return true;
			}
			
			if (!validaCpfCnpj(retiraCaracteres($(this).val(),"0123456789",true),1)) {
				showError("error","CPF inv&aacute;lido.","Alerta - Aimaro","$('#nrcpfseg','#frmHabilitaCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
				return false;
			}
			
			carregarRepresentante("H",2,$(this).val());
		} else {
			$("#nmpesseg","#frmHabilitaCartao").val("").prop("disabled",true).attr("class","campoTelaSemBorda");
			$("#dtnasseg","#frmHabilitaCartao").val("").prop("disabled",true).attr("class","campoTelaSemBorda");
		}	
		
		return true;
	});
	$("#nrcpfseg","#frmHabilitaCartao").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("INTEGER","999.999.999-99","",e); });
	$("#nrcpfseg","#frmHabilitaCartao").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("INTEGER","999.999.999-99","",e); });
	$("#nmpesseg","#frmHabilitaCartao").setMask("STRING",40,charPermitido(),"");
	$("#dtnasseg","#frmHabilitaCartao").setMask("DATE","","","divRotina");

	$("#nrcpfter","#frmHabilitaCartao").unbind("blur").unbind("keydown").unbind("keyup");
	$("#nrcpfter","#frmHabilitaCartao").bind("blur",function() {
		$(this).setMaskOnBlur("INTEGER","999.999.999-99","","divRotina");
		
		if ($(this).val() != "" && $(this).val() != "000.000.000-00") {
			if ($(this).val() == cpfterat) {
				return true;
			}
			
			if (!validaCpfCnpj(retiraCaracteres($(this).val(),"0123456789",true),1)) {
				showError("error","CPF inv&aacute;lido.","Alerta - Aimaro","$('#nrcpfter','#frmHabilitaCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
				return false;
			}
			
			carregarRepresentante("H",3,$(this).val());
		} else {
			$("#nmpester","#frmHabilitaCartao").val("").prop("disabled",true).attr("class","campoTelaSemBorda");
			$("#dtnaster","#frmHabilitaCartao").val("").prop("disabled",true).attr("class","campoTelaSemBorda");
		}	
		
		return true;
	});
	$("#nrcpfter","#frmHabilitaCartao").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("INTEGER","999.999.999-99","",e); });
	$("#nrcpfter","#frmHabilitaCartao").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("INTEGER","999.999.999-99","",e); });
	$("#nmpester","#frmHabilitaCartao").setMask("STRING",40,charPermitido(),"");
	$("#dtnaster","#frmHabilitaCartao").setMask("DATE","","","divRotina");

	$("#nrcpfpri","#frmHabilitaCartao").trigger("blur");
	$("#nrcpfseg","#frmHabilitaCartao").trigger("blur");
	$("#nrcpfter","#frmHabilitaCartao").trigger("blur");

	// Mostra o div da Tela da opção
	$("#divOpcoesDaOpcao1").css("display","block");
	$("#divConteudoCartoes").css("display","none");

	mostraDivDadosHabilita();

	// ALTERAÇÃO 001: Chama formatação do formulário
	habilitaAvalista(true);
	layoutPadrao();
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>
