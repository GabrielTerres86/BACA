<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 29/04/2014
	 * OBJETIVO     : Cabecalho para a tela INDICE
	 * --------------
	 * ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	 * --------------
	 */
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<style>
.ui-datepicker-trigger{
	float:left;
	margin-left:6px;
	margin-top:6px;
}

.radio{
	float:left;
	margin-left:6px;
	margin-top:6px;
}
</style> 

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>	
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" onChange="limpaTela();">
					<?php if ($glbvars["cdcooper"] == 3) { ?>
						<option value="A" >A - Altera&ccedil;&atilde;o de indexador de remunera&ccedil;&atilde;o</option>
					<?php } ?>
					<option value="C" >C - Consultar indexadores de remunera&ccedil;&atilde;o</option>
					<?php if ($glbvars["cdcooper"] == 3) { ?>
						<option value="I" >I - Inclus&atilde;o de novo indexador de remunera&ccedil;&atilde;o</option>
					<?php } ?>
					<option value="R" >R - Relat&oacute;rio dos indexadores de remunera&ccedil;&atilde;o</option>
					<?php if ($glbvars["cdcooper"] == 3) { ?>
						<option value="T" >T - Cadastro da taxa do indexador de remunera&ccedil;&atilde;o</option>
					<?php } ?>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick = "escolheOpcao();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
	
	<div id="divIndice">
		<div id="divInclusao" style="display:none;" >
			<table>
				<tr>	
					<td>
						<label for="nmdindex"><? echo utf8ToHtml('Indexador:') ?></label>
						<input type="text" id="nmdindex" name="nmdindex" value="" />
					</td>
				</tr>			
				<tr>	
					<td>
						<label for="idperiodI"><? echo utf8ToHtml('Periodicidade:') ?></label>
						<select id="idperiodI" name="idperiodI" >
							<option value="3" >Anual</option>
							<option value="1" >Diaria</option>
							<option value="2" >Mensal</option>
						</select>
					</td>
				</tr>
				<tr>	
					<td>
						<label for="idexpresI"><? echo utf8ToHtml('Taxa Expressa:') ?></label>
						<select id="idexpresI" name="idexpresI" >
							<option value="2" >Ao Ano</option>
							<option value="1" >Ao M&ecirc;s</option>
						</select>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="idcadastI"><? echo utf8ToHtml('Forma de Cadastro:') ?></label>
						<input type="radio" name="idcadastI" id="idcadastI" value="1" onKeyPress="msgConfirmacao();"><label>&nbsp;&nbsp;&nbsp;Manual</label>
						<input type="radio" name="idcadastI" id="idcadastI" value="2" style="margin-left: 30px;" onKeyPress="msgConfirmacao();" ><label>&nbsp;&nbsp;&nbsp;Autom&aacute;tico</label>
					</td>
				</tr>
				<tr>
					<td>
						<a href="#" class="botao" id="btSalvar" name="btSalvar" onClick="msgConfirmacao(); return false;">Prosseguir</a>
						<a href="#" class="botao" id="btVoltar" name="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
					</td>
				</tr>
			</table>
		</div>
		
		<div id="divAlteracao" style="display:none;" >
			<table>
				<tr>	
					<td>
						<label for="cddindexA"><? echo utf8ToHtml('Indexador:') ?></label>
						<select id="cddindexA" name="cddindexA" ></select>
					</td>
				</tr>			
				<tr>	
					<td>
						<label for="idperiodA"><? echo utf8ToHtml('Periodicidade:') ?></label>
						<select id="idperiodA" name="idperiodA" >
							<option value="3" >Anual</option>
							<option value="1" >Diaria</option>
							<option value="2" >Mensal</option>
						</select>
					</td>
				</tr>
				<tr>	
					<td>
						<label for="idexpresA"><? echo utf8ToHtml('Taxa Expressa:') ?></label>
						<select id="idexpresA" name="idexpresA" >
							<option value="2" >Ao Ano</option>
							<option value="1" >Ao M&ecirc;s</option>
						</select>
					</td>
				</tr>
				<tr>		
					<td>
						<label for="idcadastA"><? echo utf8ToHtml('Forma de Cadastro:') ?></label>
						<input type="radio" name="idcadastA" id="idcadastA" value="1" ><label>&nbsp;&nbsp;&nbsp;Manual</label>
						<input type="radio" name="idcadastA" id="idcadastA" value="2" style="margin-left: 30px;" ><label>&nbsp;&nbsp;&nbsp;Autom&aacute;tico</label>
					</td>
				</tr>
				<tr>
					<td>
						<a href="#" class="botao" id="btSalvar" name="btSalvar" onClick="msgConfirmacao(); return false;">Prosseguir</a>
						<a href="#" class="botao" id="btVoltar" name="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
					</td>
				</tr>
			</table>
		</div>
		
		<div id="divTaxa" style="display:none;" >
			<table>
				<tr>	
					<td>
						<label for="cddindexT"><? echo utf8ToHtml('Indexador:') ?></label>
						<select id="cddindexT" name="cddindexT" ></select>
					</td>
				</tr>			
				<tr>	
					<td>
						<label for="dtperiod"><? echo utf8ToHtml('Data Per&iacute;odo:') ?></label>
						<input type="text" name="dtperiod" id="dtperiod" > 
					</td>
				</tr>
				<tr>	
					<td>
						<label for="vlrdtaxa"><? echo utf8ToHtml('Valor da Taxa:') ?></label>
						<input type="text" name="vlrdtaxa" id="vlrdtaxa" class="porcento_7" value="0,00">
					</td>
				</tr>
				<tr>
					<td>
						<a href="#" class="botao" id="btSalvar" name="btSalvar" onClick="msgConfirmacao(); return false;">Prosseguir</a>
						<a href="#" class="botao" id="btVoltar" name="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
					</td>
				</tr>
			</table>
		</div>
		
		<div id="divConsultaRel" style="display:none;" >
			<table>
				<tr>	
					<td>
						<label for="cddindexC"><? echo utf8ToHtml('Indexador:') ?></label>
						<select id="cddindexC" name="cddindexC" ></select>
					</td>
				</tr>
			</table>
			
			<div id="dtPeriodAno" name="dtPeriodAno">
				<table>
					<tr>	
						<td>
							<label for="dtiniperAno"><? echo utf8ToHtml('Data Inicial Per&iacute;odo:') ?></label>
							<input type="text" name="dtiniperAno" id="dtiniperAno" readonly="readonly" >
						</td>
					</tr>
					<tr>	
						<td>
							<label for="dtfimperAno"><? echo utf8ToHtml('Data Final Per&iacute;odo:') ?></label>
							<input type="text" name="dtfimperAno" id="dtfimperAno" readonly="readonly" >
						</td>
					</tr>
				</table>
			</div>
			
			<div id="dtPeriodMes" name="dtPeriodMes">
				<table>
					<tr>	
						<td>
							<label for="dtiniperMes"><? echo utf8ToHtml('Data Inicial Per&iacute;odo:') ?></label>
							<input type="text" name="dtiniperMes" id="dtiniperMes" readonly="readonly" >
						</td>
					</tr>
					<tr>	
						<td>
							<label for="dtfimperMes"><? echo utf8ToHtml('Data Final Per&iacute;odo:') ?></label>
							<input type="text" name="dtfimperMes" id="dtfimperMes" readonly="readonly" >
						</td>
					</tr>
				</table>
			</div>
						
			<table>
				<tr>
					<td>
						<div id="btnConsulta" name="btnConsulta">
							<a href="#" class="botao" id="btSalvar" name="btSalvar" onClick="msgConfirmacao(); return false;">Prosseguir</a>
							<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>
						</div>
					</td>
				</tr>
			</table>
		</div>
	</div>
</form>

<form name="frmImprimir" id="frmImprimir" style="display:none">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input name="nmarquiv" id="nmarquiv" type="hidden" value="" />
</form>

<script>

	$.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );

	/*Mascara referente a campo de inicio de periodo de Ano*/
	$('#dtiniperAno').datepicker({
		dateFormat: "yy",
		changeYear: true,
		changeMonth: false,
		changeDay: false,
		showOn: "button",
		buttonImage: "../../imagens/geral/btn_calendario.gif",
		buttonImageOnly: true
	});
  
	/*Mascara referente a campo de fim de periodo de Ano*/
	$('#dtfimperAno').datepicker({
		dateFormat: "yy",
		changeYear: true,
		changeMonth: false,
		changeDay: false,
		showOn: "button",
		buttonImage: "../../imagens/geral/btn_calendario.gif",
		buttonImageOnly: true
	});
	
	/*Mascara referente a campo de inicio de periodo de Mes*/
	$('#dtiniperMes').datepicker({
		dateFormat: "mm/yy",
		changeYear: true,
		changeMonth: true,
		changeDay: false,
		showOn: "button",
		buttonImage: "../../imagens/geral/btn_calendario.gif",
		buttonImageOnly: true
	});
  
	/*Mascara referente a campo de fim de periodo de Mes*/
	$('#dtfimperMes').datepicker({
		dateFormat: "mm/yy",
		changeYear: true,
		changeMonth: true,
		changeDay: false,
		showOn: "button",
		buttonImage: "../../imagens/geral/btn_calendario.gif",
		buttonImageOnly: true
	});
		
</script>