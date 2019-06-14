<?php 

	/**************************************************************************************
	 Fonte: acumula_simular.php                                       
	 Autor: David                                                     
	 Data : Outubro/2009          					       Última alteração: 30/04/2014
	                                                                  
	 Objetivo  : Script para simular saldo acumulado                  
	                                                                  
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p 
	                          para a BO b1wgen0081.p (Adriano).     
							  
				 30/04/2014 - Ajuste referente ao projeto Captação							 
						      (Adriano). 
							  
	**************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetTipos  = "";
	$xmlGetTipos .= "<Root>";
	$xmlGetTipos .= "	<Cabecalho>";
	$xmlGetTipos .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetTipos .= "		<Proc>obtem-tipos-aplicacao</Proc>";
	$xmlGetTipos .= "	</Cabecalho>";
	$xmlGetTipos .= "	<Dados>";
	$xmlGetTipos .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetTipos .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetTipos .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetTipos .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetTipos .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetTipos .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetTipos .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetTipos .= "		<idseqttl>1</idseqttl>";			
	$xmlGetTipos .= "	</Dados>";
	$xmlGetTipos .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetTipos);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjTipos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjTipos->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTipos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$tipos   = $xmlObjTipos->roottag->tags[0]->tags;	
	$qtTipos = count($tipos);
	
	// Flag que indicam se forms devem ser criados
	$flrdcpre = false;
	$flrdcpre = false;
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

	<form action="" method="post" name="frmSimular" id="frmSimular" class="formulario">
		<fieldset>
			<legend>Simular Saldo Acumulado</legend>		
			<label for="tpaplica">Tipo da Aplica&ccedil;&atilde;o:</label>
			<select name="tpaplica" id="tpaplica" >
				<?php 
				for ($i = 0; $i < $qtTipos; $i++) { 
					if ($tipos[$i]->tags[2]->cdata == "1") {
						$flrdcpre = true;
					} elseif ($tipos[$i]->tags[2]->cdata == "2") {
						$flrdcpos = true;
					}
				?>
				<option value="<?php echo $tipos[$i]->tags[0]->cdata; ?>"><?php echo $tipos[$i]->tags[1]->cdata; ?></option>
				<?php 
				} 
				?>
			</select>
		</fieldset>
	</form>
	
	
	
	<?php 
	if ($flrdcpre) { 
	?>
	<div id="divSimulaRDCPRE">
		<form action="" method="post" name="frmSimulaRDCPRE" id="frmSimulaRDCPRE" class="formulario">	
			<fieldset>
				<legend>RDCPRE</legend>		
				<input type="hidden" name="cdperapl" id="cdperapl" value="1">
				<input type="hidden" name="qtdiacar" id="qtdiacar" value="0">	
			
				<label for="vlaplica">Valor:</label>
				<input type="text" id="vlaplica" name="vlaplica" autocomplete="no" value="0,00">
				
				<label for="qtdiaapl">Qtde.Dias:</label>
				<input type="text" id="qtdiaapl" name="qtdiaapl" autocomplete="no" value="0">
				
				<label for="dtvencto">Vencimento:</label>
				<input type="text" id="dtvencto" name="dtvencto" autocomplete="no" value="">
				
				<label for="txaplica">Taxa Contrato:</label>
				<input type="text" id="txaplica" name="txaplica" autocomplete="no" value="000,000000">
				
				<label for="txaplmes">Taxa Min&iacute;ma:</label>
				<input type="text" id="txaplmes" name="txaplmes" autocomplete="no" value="000,000000">
				
				<label for="vlsldrdc">Saldo:</label>
				<input type="text" id="vlsldrdc" name="vlsldrdc"  autocomplete="no" value="0,00">
			</fieldset>
		</form>
	</div>	
	<?php
	}
	?>
	
	<?php
	if ($flrdcpos) { 
	?>
	<div id="divSimulaRDCPOS">
		<form action="" method="post" name="frmSimulaRDCPOS" id="frmSimulaRDCPOS" class="formulario">
			<fieldset>
				<legend>RDCPOS</legend>		

				<input type="hidden" name="cdperapl" id="cdperapl" value="0">

				<label for="vlaplica">Valor:</label>
				<input type="text" id="vlaplica" name="vlaplica" autocomplete="no" value="0,00">
				
				<div id="divCarencia" style="position: absolute; visibility: hidden; background-color: #FFFFFF; border: 1px solid #666666; padding: 2px; "></div>
				<label for="qtdiacar">Car&ecirc;ncia:</label>	
				<input type="text" id="qtdiacar" name="qtdiacar" autocomplete="no" value="0">
				<a href="#" onClick="obtemCarencia();return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
					
				<label for="dtcarenc">Data Car&ecirc;ncia:</label>
				<input type="text" id="dtcarenc" name="dtcarenc" autocomplete="no" value="">
			
				<label for="dtvencto">Vencimento:</label>
				<input type="text" id="dtvencto" name="dtvencto" autocomplete="no" value="">
				
				<label for="txaplica">Taxa Contrato:</label>
				<input type="text" id="txaplica" name="txaplica" autocomplete="no" value="000,000000">
					
				<label for="txaplmes">Taxa Min&iacute;ma:</label>
				<input type="text" id="txaplmes" name="txaplmes" autocomplete="no" value="000,000000">
			</fieldset>
		</form>
	</div>	
	<?php
	}
	?>
	
	<table width="315" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<table width="300" border="0" cellpadding="1" cellspacing="2">	
					<tr style="background-color: #F4D0C9;" height="20">				
						<td width="70" class="txtNormalBold" align="right">Aplica&ccedil;&atilde;o</td>
						<td width="110" class="txtNormalBold">Tipo da Aplica&ccedil;&atilde;o</td>
						<td class="txtNormalBold" align="right">Saldo na Data</td>
					</tr>						
				</table>
			</td>
		</tr>				
		<tr>
			<td>
				<div id="divSaldosAcumulados" style="overflow-y: scroll; overflow-x: hidden; height: 72px; width: 100%;">
					<table width="100%" border="0" cellpadding="1" cellspacing="2">	
						<tr>
							<td width="70" class="txtNormal" align="right">&nbsp;</td>
							<td width="110" class="txtNormal">&nbsp;</td>
							<td class="txtNormal" align="right">&nbsp;</td>
						</tr>															
					</table>
				</div>
			</td>
		</tr>
		<tr>
			<td>	
				<table width="300" border="0" cellpadding="1" cellspacing="2">		
					<tr style="background-color: #FFFFFF;">
						<td width="70" class="txtNormal" align="right">&nbsp;</td>
						<td width="110" class="txtNormal">TOTAL ACUMULADO</td>
						<td class="txtNormal" align="right" id="tdTotal">0,00</td>
					</tr>	
				</table>
			</td>
		</tr>
	</table>	

	<div id="divBotoes">
		
		<a href="#" class="botao" id="btVoltar" onClick="voltarDivAcumula();return false;">Voltar</a>
		<a href="#" class="botao" id="btSimular" onClick="calcularSaldoAcumulado();return false;">Simular</a>
			
	</div>

<script type="text/javascript">
	
	// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
	$("#divConteudoOpcao").css("height","275px");

	/*RDCPRE*/
	$("#vlaplica","#frmSimulaRDCPRE").setMask("DECIMAL","zzz.zzz.zz9,99","","");	

	$("#qtdiaapl","#frmSimulaRDCPRE").unbind("blur");
	$("#qtdiaapl","#frmSimulaRDCPRE").unbind("keydown");
	$("#qtdiaapl","#frmSimulaRDCPRE").unbind("keyup");
	$("#qtdiaapl","#frmSimulaRDCPRE").bind("blur",function() {		
		if ($(this).val() == "" || parseInt($(this).val(),10) <= 0) {
			$("#dtvencto","#frmSimulaRDCPRE").val("");
		}
		
		if (!($(this).setMaskOnBlur("INTEGER","zz9","","divRotina"))) {
			return false;
		}
		
		return calculaPermanencia($(this).attr("id"),$(this).val());			
	});
	$("#qtdiaapl","#frmSimulaRDCPRE").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("INTEGER","zz9","",e); });
	$("#qtdiaapl","#frmSimulaRDCPRE").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("INTEGER","zz9","",e); });

	$("#dtvencto","#frmSimulaRDCPRE" ).unbind("blur");
	$("#dtvencto","#frmSimulaRDCPRE" ).unbind("keydown");
	$("#dtvencto","#frmSimulaRDCPRE" ).unbind("keyup");
	$("#dtvencto","#frmSimulaRDCPRE" ).bind("blur",function() {
		if ($(this).val() == "") {
			$("#qtdiaapl","#frmSimulaRDCPRE").val("0");
		}
		
		if (!($(this).setMaskOnBlur("DATE","","","divRotina"))) {
			return false;
		}		 
		
		return calculaPermanencia($(this).attr("id"),$(this).val());			
	});
	$("#dtvencto","#frmSimulaRDCPRE" ).bind("keydown",function(e) { return $(this).setMaskOnKeyDown("DATE","","",e); });
	$("#dtvencto","#frmSimulaRDCPRE" ).bind("keyup",function(e) { return $(this).setMaskOnKeyUp("DATE","","",e); });

	
	/*RDCPOS*/
	$("#vlaplica","#frmSimulaRDCPOS").unbind("blur");
	$("#vlaplica","#frmSimulaRDCPOS").unbind("keydown");
	$("#vlaplica","#frmSimulaRDCPOS").unbind("keyup");
	$("#vlaplica","#frmSimulaRDCPOS").bind("blur",function() {
		if (parseFloat($(this).val().replace(/\./,"").replace(",",".")) <= 0) {
			return true;
		}
		
		if (!($(this).setMaskOnBlur("DECIMAL","zz.zzz.zz9,99","","divRotina"))) {
			return false;
		}		 
		
		return obtemCarencia();
		
	});
	$("#vlaplica","#frmSimulaRDCPOS").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("DECIMAL","zz.zzz.zz9,99","",e); });
	$("#vlaplica","#frmSimulaRDCPOS").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("DECIMAL","zz.zzz.zz9,99","",e); });
	
	$("#qtdiacar","#frmSimulaRDCPOS").setMask("INTEGER","zz9","","");
	
	$("#dtvencto","#frmSimulaRDCPOS").unbind("blur");
	$("#dtvencto","#frmSimulaRDCPOS").unbind("keydown");
	$("#dtvencto","#frmSimulaRDCPOS").unbind("keyup");
	$("#dtvencto","#frmSimulaRDCPOS").bind("change",function() {	
				
		if (!($(this).setMaskOnBlur("DATE","","","divRotina"))) {
			return false;
		}		 
		aux_qtdiaapl = 0;
		
		return calculaPermanencia($(this).attr("id"),$(this).val());			
	});
	
	$("#dtvencto","#frmSimulaRDCPOS").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("DATE","","",e); });
	$("#dtvencto","#frmSimulaRDCPOS").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("DATE","","",e); });
		

    $("#tpaplica","#frmSimular").unbind("change");
	$("#tpaplica","#frmSimular").bind("change",function() {
		var strHTML = "";		
		strHTML += '<table width="100%" border="0" cellpadding="1" cellspacing="2">';
		strHTML += '	<tr>';
		strHTML += '		<td width="70" class="txtNormal" align="right">&nbsp;</td>';
		strHTML += '		<td width="110" class="txtNormal">&nbsp;</td>';
		strHTML += '		<td class="txtNormal" align="right">&nbsp;</td>';
		strHTML += '	</tr>';															
		strHTML += '</table>';
		
		$("#divSaldosAcumulados").html(strHTML);
		$("#tdTotal").html("0,00");
		
		$("#tpaplica option","#frmSimular").each(function() {
			$("#divSimula" + $(this).text()).css("display","none");
		});	
		
		$("#divSimula" + $("#tpaplica option:selected","#frmSimular").text()).css("display","block");	
		
		if ($("#tpaplica option:selected","#frmSimular").text() == "RDCPRE") {
			$("#vlaplica","#frmSimulaRDCPRE").val("0,00");
			$("#qtdiaapl","#frmSimulaRDCPRE").val("0");
			$("#dtvencto","#frmSimulaRDCPRE").val("");
			$("#txaplica","#frmSimulaRDCPRE").val("0,000000");
			$("#txaplmes","#frmSimulaRDCPRE").val("0,000000");
			$("#vlsldrdc","#frmSimulaRDCPRE").val("0,00");
		} else if ($("#tpaplica option:selected","#frmSimular").text() == "RDCPOS") {
			$("#vlaplica","#frmSimulaRDCPOS").val("0,00");
			$("#qtdiacar","#frmSimulaRDCPOS").val("0");
			$("#dtcarenc","#frmSimulaRDCPOS").val("");
			$("#dtvencto","#frmSimulaRDCPOS").val("");
			$("#txaplica","#frmSimulaRDCPOS").val("0,000000");
			$("#txaplmes","#frmSimulaRDCPOS").val("0,000000");			
			$("#cdperapl","#frmSimulaRDCPOS").val("0");
		}
		
	});

	$("#tpaplica","#frmSimular").trigger("change");

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));	
</script>