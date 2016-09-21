<?
/*!
 * FONTE        : form_relatorio.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 26/10/2011
 * OBJETIVO     : Formulario com os filtros do relatorio
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout, botões (David Kruger).
 *                24/07/2013 - Ajustado para permitir imprimir o relatório de cartões magnéticos. (James)
 *                13/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *                27/05/2014 - Incluido a informação de espécie de deposito e
							   relatório do mesmo. (Andre Santos - SUPERO). 
 * --------------
 */
?>
<form id="frmRelatorio" name="frmRelatorio" class="formulario" onSubmit="return false">
		
	<fieldset>	
		
		<legend><? echo utf8ToHtml('Relatório') ?></legend>
		
		<label for="opcaorel"><? echo utf8ToHtml('Tipo do Relatório:') ?></label>	
		<select name="opcaorel" id="opcaorel">
		  <option value="1"><? echo utf8ToHtml('Movimentações') ?></option>
		  <option value="2"><? echo utf8ToHtml('Cartões Magnéticos') ?></option>
		  <option value="3"><? echo utf8ToHtml('Depósitos') ?></option>
		</select>
		
		<div id="divRel1" class="divRel1" style="display:block">
			<br /><br />
			
			<label for="lgagetfn"><? echo utf8ToHtml('PA:') ?></label>	
			<select name="lgagetfn" id="lgagetfn">
			  <option value="no">Nao</option>
			  <option value="yes">Sim</option>
			</select>
			<a href="#" class="botao" id="btnOK">OK</a>
			
			<label for="cdagetfn"><? echo utf8ToHtml('Nr:') ?></label>
			<input name="cdagetfn" id="cdagetfn" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
			<input name="dsagetfn" id="dsagetfn" type="text" value="" />
		</div>

		<div id="divRel2"  class="divRel2" style="display:none">		
			<br />
			<label for="nrterfin1"><? echo utf8ToHtml('Nr Terminal de Saque:') ?></label>
			<input name="nrterfin1" id="nrterfin1" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
			<input name="dsterfin1" id="dsterfin1" type="text" value="<? echo $dsterfin1 ?>" />
			<a href="#" class="botao" id="btnOK1">OK</a>
			<br />
		</div>
		
		<label for="dtmvtini"><? echo utf8ToHtml('Data:') ?></label>
		<input name="dtmvtini" id="dtmvtini" type="text" value="" />

		<label for="dtmvtfim"><? echo utf8ToHtml('até:') ?></label>
		<input name="dtmvtfim" id="dtmvtfim" type="text" value="" />

		<label for="tiprelat"><? echo utf8ToHtml('Formato:') ?></label>
		<select name="tiprelat" id="tiprelat">
		  <option value="yes">Analitico</option>
		  <option value="no">Sintetico</option>
		</select>
		
		<label for="cdsitenv"><? echo utf8ToHtml('Situacao:') ?></label>	
		<select name="cdsitenv" id="cdsitenv">
		  <option value="9"><? echo utf8ToHtml('Todos') ?></option>
		  <option value="0"><? echo utf8ToHtml('Não Liberado') ?></option>
		  <option value="1"><? echo utf8ToHtml('Liberado') ?></option>
		  <option value="2"><? echo utf8ToHtml('Descartado') ?></option>
		  <option value="3"><? echo utf8ToHtml('Recolhido') ?></option>
		</select>

		<br style="clear:both" />
		
	</fieldset>

</form>

<div id="divBotoes" style="margin-bottom:8px">
	<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Continuar</a>
</div>

<script> 
	$(document).ready(function(){
		highlightObjFocus($('#frmRelatorio'));
	});
</script>
