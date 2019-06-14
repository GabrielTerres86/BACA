<?php 

	/************************************************************************
	 Fonte: agendamento_resgate.php                                             
	 Autor: Douglas
	 Data : Setembro/2014                Última Alteração:
	                                                                  
	 Objetivo  : Tela Principal da rotina para incluir agendamento de
	             resgate das aplicações
	                                                                  	 
	 Alterações: 17/04/2018 - Incluida verificacao de adesao do produto 
                              pelo tipo de conta. PRJ366 (Lombardi)

	************************************************************************/

	include("agendamento.php");

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".   41    ."</cdprodut>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}
	
?>
var strHTML = "";
strHTML += '<form id="frmAgendamentoResgate">';
strHTML += '	<table width="100%">';
strHTML += '		<tr>';
strHTML += '			<td colspan="5">';
strHTML += '				<input id="qtmesage" name="qtmesage" type="hidden" maxlength="12" class="campo" value="<?php echo $qtmesage;?>">';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td width="120px" align="right">';
strHTML += '				<label class="rotulo txtNormalBold" for="vlparaar">Valor para Resgate:</label>';
strHTML += '			</td>';
strHTML += '			<td colspan="4">';
strHTML += '				<input id="vlparaar" name="vlparaar" type="text" class="campo" maxlength="12">';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td width="120px" align="right">';
strHTML += '				<label class="rotulo txtNormalBold" for="flgtipin">Tipo de Resgate:</label>';
strHTML += '			</td>';
strHTML += '			<td colspan="4">';
strHTML += '				<select id="flgtipin" name="flgtipin" class="campo" style="width:100px">';
strHTML += '					<option value="0">Unica</option>';
strHTML += '					<option value="1">Mensal</option>';
strHTML += '				</select>';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td width="120px" align="right">';
strHTML += '				<label class="rotulo txtNormalBold" for="dtiniaar" id="label_data">Data:</label>';
strHTML += '			</td>';
strHTML += '			<td colspan="4">';
strHTML += '				<input id="dtiniaar" name="dtiniaar" type="text" class="campo" maxlength="10" style="width:130px" value="<?php echo $proxima_data; ?>">';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td width="120px" align="right">';
strHTML += '				<label class="rotulo txtNormalBold" for="dtdiaaar" id="label_no_dia">Creditar no dia</label>';
strHTML += '			</td>';
strHTML += '			<td width="140px">';
strHTML += '				<input id="dtdiaaar" name="dtdiaaar" type="text" class="campo" maxlength="2" style="width:130px">';
strHTML += '			</td>';
strHTML += '			<td width="120px">';
strHTML += '				<label class="rotulo txtNormalBold" for="qtmesaar" id="label_do_mes">de cada mes, durante</label>';
strHTML += '			</td>';
strHTML += '			<td width="60px">';
strHTML += '				<input id="qtmesaar" name="qtmesaar" type="text" class="campo" style="width:50px" maxlength="3">';
strHTML += '			</td>';
strHTML += '			<td align="left" width="60px">';
strHTML += '				<label class="rotulo txtNormalBold" id="label_mes">mes(es)</label>';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td colspan="5" class="rotulo txtNormalBold">';
strHTML += '				<label class="rotulo txtNormalBold">Caso a data do agendamento seja um feriado ou final de semana, o processamento será realizado no próximo dia útil.</label>';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '	</table>';
strHTML += '</form>';
strHTML += '<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">';
strHTML += '	<a href="#" class="botao" id="btVoltar"    onClick="voltarTipoAgendamento();return false;">Voltar</a>';
strHTML += '	<a href="#" class="botao" id="btConfirmar" onClick="confirmarAgendamentoResgate();return false;">Confirmar</a>';
strHTML += '</div>';


// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","150px");

// Mostra div para op&ccedil;&atilde;o de resgate
$("#divTipoAgendamento").css("display","none");
$("#divAgendamentoResgate").html(strHTML);
$("#divAgendamentoResgate").css("display","block");

$("#dtdiaaar","#frmAgendamentoResgate").setMask("INTEGER","z9","","divRotina");
$("#qtmesaar","#frmAgendamentoResgate").setMask("INTEGER","zz9","","divRotina");

$("#dtiniaar","#frmAgendamentoResgate").setMask("DATE","","","divRotina");
$("#vlparaar","#frmAgendamentoResgate").unbind("blur");
$("#vlparaar","#frmAgendamentoResgate").unbind("keydown");
$("#vlparaar","#frmAgendamentoResgate").unbind("keyup");
$("#vlparaar","#frmAgendamentoResgate").bind("blur",function(e) { return $(this).setMaskOnBlur("DECIMAL","zz.zzz.zz9,99","",e); });
$("#vlparaar","#frmAgendamentoResgate").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("DECIMAL","zz.zzz.zz9,99","",e); });
$("#vlparaar","#frmAgendamentoResgate").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("DECIMAL","zz.zzz.zz9,99","",e); });	
$("#vlparaar","#frmAgendamentoResgate").focus();

$("#qtmesaar","#frmAgendamentoResgate").unbind("blur");
$("#qtmesaar","#frmAgendamentoResgate").bind("blur",function() { validaQtdMeses("R"); });

$("#flgtipin","#frmAgendamentoResgate").unbind("change");
$("#flgtipin","#frmAgendamentoResgate").bind("change",function() { habilitaCampoAgendamento("R",this.value); });	

$("#dtdiaaar","#frmAgendamentoResgate").unbind("change");
$("#dtdiaaar","#frmAgendamentoResgate").bind("change",function() { validaQtdDias(this.value,"R"); });	

habilitaCampoAgendamento("R");

// Esconde mensagem de aguardo
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));