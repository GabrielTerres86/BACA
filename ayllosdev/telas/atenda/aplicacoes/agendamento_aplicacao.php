<?php 
	/************************************************************************
	 Fonte: agendamento_aplicacao.php                                             
	 Autor: Douglas
	 Data : Setembro/2014                Última Alteração: 13/11/2014
	                                                                  
	 Objetivo  : Tela Principal da rotina para incluir agendamento de
	             aplicação para novas aplicações
	                                                                  	 
	 Alterações: 20/10/2014 - Ajustado os scripts dos campos para buscar o 
	                          vencimento e o calculo dos dias. (Douglas - 
							  Projeto Captação Internet 2014/2)
							  
				 13/11/2014 - Ajuste para aumentar o height do divConteudoOpcao
							  e aumentar o width do td do campo qtmesaar
							  (Adriano).

	************************************************************************/
	
	include("agendamento.php");
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>". 3 ."</cdprodut>"; //Aplicação
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}
	
?>
var strHTML = "";
strHTML += '<form id="frmAgendamentoAplicacao">';
strHTML += '	<table width="100%">';
strHTML += '		<tr>';
strHTML += '			<td colspan="3">';
strHTML += '				<input id="qtmesage" name="qtmesage" type="hidden" maxlength="12" class="campo" value="<?php echo $qtmesage;?>">';
strHTML += '			</td>';
strHTML += '			<td colspan="2">';
strHTML += '				<input id="dtmvtolt" name="dtmvtolt" type="hidden" maxlength="10" class="campo" value="<?php echo $proxima_data; ?>">';
strHTML += '			</td>';
strHTML += '		<tr>';
strHTML += '		<tr>';
strHTML += '			<td align="right" width="160px">';
strHTML += '				<label class="rotulo txtNormalBold" for="vlparaar">Valor para Aplica&ccedil;&atilde;o:</label>';
strHTML += '			</td>';
strHTML += '			<td>';
strHTML += '				<input id="vlparaar" name="vlparaar" type="text" maxlength="12" class="campo">';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td align="right" width="160px" >';
strHTML += '				<label class="rotulo txtNormalBold" for="flgtipin">Tipo de aplica&ccedil;&atilde;o:</label>';
strHTML += '			</td>';
strHTML += '			<td>';
strHTML += '				<select id="flgtipin" name="flgtipin" class="campo">';
strHTML += '					<option value="0">Unica</option>';
strHTML += '					<option value="1">Mensal</option>';
strHTML += '				</select>';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td align="right" width="160px">';
strHTML += '				<label class="rotulo txtNormalBold" for="dtiniaar" id="label_data">Data:</label>';
strHTML += '			</td>';
strHTML += '			<td>';
strHTML += '				<input id="dtiniaar" name="dtiniaar" type="text" maxlength="10" class="campo" style="width:130px" value="<?php echo $proxima_data;?>">';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td align="right" width="160px">';
strHTML += '				<label class="rotulo txtNormalBold" for="dtdiaaar" id="label_no_dia">Debitar no dia:</label>';
strHTML += '			</td>';
strHTML += '			<td width="140px">';
strHTML += '				<input id="dtdiaaar" name="dtdiaaar" type="text" class="campo" maxlength="2" style="width:130px">';
strHTML += '			</td>';
strHTML += '			<td width="130px">';
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
strHTML += '			<td align="right" width="160px">';
strHTML += '				<label class="rotulo txtNormalBold" for="qtdiacar">Car&ecirc;ncia:</label>';
strHTML += '			</td>';
strHTML += '			<td>';
strHTML += '			    <select id="qtdiacar" name="qtdiacar" class="campo">';
							<?php
								// Leitura das aplicações 
								for ($j = 0; $j < count($carencias); $j++) {	
								?>
									strHTML += '<option value="<?php echo getByTagName($carencias[$j]->tags,"qtdiacar"); ?>"><?php echo getByTagName($carencias[$j]->tags,"qtdiacar"); ?> Dias</option>';
									arrayCarencias[<?php echo getByTagName($carencias[$j]->tags,"qtdiacar"); ?>] = "<?php echo getByTagName($carencias[$j]->tags,"qtdiafim"); ?>";
								<?php
								}																								
							?>
strHTML += '				</select>';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td align="right" width="160px">';
strHTML += '				<label class="rotulo txtNormalBold" for="dtvencto">Vencimento:</label>';
strHTML += '			</td>';
strHTML += '			<td>';
strHTML += '				<input id="dtvencto" name="dtvencto" type="text" maxlength="10" class="campo">';
strHTML += '			</td>';
strHTML += '			<td align="left" width="160px" colspan="2">';
strHTML += '				<label class="rotulo txtNormalBold" for="dtvencto">do 1º agendamento</label>';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td align="right" width="160px">';
strHTML += '				<label class="rotulo txtNormalBold" for="dtvendia" id="label_vcto">Vencimento em dias:</label>';
strHTML += '			</td>';
strHTML += '			<td align="left" class="txtNormal12 txtNormalMobileSmall">';
strHTML += '				<input id="dtvendia" name="dtvendia" type="text" maxlength="10" readonly="readonly" class="campo">';
strHTML += '			</td>';
strHTML += '			<td align="left" width="160px" colspan="2">';
strHTML += '				<label class="rotulo txtNormalBold" for="dtvendia" id="label_vcto_dias">para todos os agendamentos</label>';
strHTML += '			</td>';
strHTML += '		</tr>';
strHTML += '		<tr>';
strHTML += '			<td colspan="5" class="rotulo txtNormalBold">';
strHTML += '				<label class="rotulo txtNormalBold">A rentabilidade contratada ser&aacute; confirmada no momento de cada aplica&ccedil;&atilde;o considerando a car&ecirc;ncia selecionada, de acordo com a politica de rentabilidade de sua cooperativa.</label>';
strHTML += '			</td>';
strHTML += '		<tr>';
strHTML += '		<tr>';
strHTML += '			<td colspan="5" class="rotulo txtNormalBold">';
strHTML += '				<label class="rotulo txtNormalBold">Caso a data do agendamento seja um feriado ou final de semana, o processamento ser&aacute; realizado no pr&oacute;ximo &uacute;til.</label>';
strHTML += '			</td>';
strHTML += '		<tr>';
strHTML += '	</table>';
strHTML += '</form>';
strHTML += '<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">';
strHTML += '	<a href="#" class="botao" id="btVoltar"    onClick="voltarTipoAgendamento();return false;">Voltar</a>';
strHTML += '	<a href="#" class="botao" id="btConfirmar" onClick="confirmarAgendamentoAplicacao();return false;">Confirmar</a>';
strHTML += '</div>';

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","250px");

// Mostra div para op&ccedil;&atilde;o de resgate
$("#divTipoAgendamento").css("display","none");
$("#divAgendamentoAplicacao").html(strHTML);
$("#divAgendamentoAplicacao").css("display","block");

$("#dtdiaaar","#frmAgendamentoAplicacao").setMask("INTEGER","z9","","divRotina");
$("#qtmesaar","#frmAgendamentoAplicacao").setMask("INTEGER","zz9","","divRotina");

$("#dtiniaar","#frmAgendamentoAplicacao").setMask("DATE","","","divRotina");
$("#dtvencto","#frmAgendamentoAplicacao").setMask("DATE","","","divRotina");
$("#vlparaar","#frmAgendamentoAplicacao").unbind("blur");
$("#vlparaar","#frmAgendamentoAplicacao").unbind("keydown");
$("#vlparaar","#frmAgendamentoAplicacao").unbind("keyup");
$("#vlparaar","#frmAgendamentoAplicacao").bind("blur",function(e) { return $(this).setMaskOnBlur("DECIMAL","zz.zzz.zz9,99","",e); });
$("#vlparaar","#frmAgendamentoAplicacao").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("DECIMAL","zz.zzz.zz9,99","",e); });
$("#vlparaar","#frmAgendamentoAplicacao").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("DECIMAL","zz.zzz.zz9,99","",e); });	
$("#vlparaar","#frmAgendamentoAplicacao").focus();

$("#qtmesaar","#frmAgendamentoAplicacao").unbind("blur");
$("#qtmesaar","#frmAgendamentoAplicacao").bind("blur",function() { validaQtdMeses("A"); });

$("#dtvencto","#frmAgendamentoAplicacao").unbind("blur");
$("#dtvencto","#frmAgendamentoAplicacao").bind("blur",function() { getIntervaloDias(); });

$("#flgtipin","#frmAgendamentoAplicacao").unbind("change");
$("#flgtipin","#frmAgendamentoAplicacao").bind("change",function() { habilitaCampoAgendamento("A",this.value); });

$("#dtdiaaar","#frmAgendamentoAplicacao").unbind("blur");
$("#dtdiaaar","#frmAgendamentoAplicacao").bind("blur",function() { onBlurDiaAgendamentoAplica(); });

$("#dtiniaar","#frmAgendamentoAplicacao").unbind("blur");
$("#dtiniaar","#frmAgendamentoAplicacao").bind("blur",function() { getDataVencto(); });

$("#qtdiacar","#frmAgendamentoAplicacao").unbind("blur");
$("#qtdiacar","#frmAgendamentoAplicacao").bind("blur",function() { getDataVencto(); });

habilitaCampoAgendamento("A");
getDataVencto();

// Esconde mensagem de aguardo
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));