<?
/*****************************************************************
  Fonte        : form_filtro.php
  Criação      : Adriano
  Data criação : Junho/2015
  Objetivo     : Form responsável por apresentar as opções de filtro para consulta
  --------------
  Alterações   : 12/01/2018 - Alterações refrente ao PJ406
  --------------
 ****************************************************************/

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>
<form id="frmFiltroPesqti" name="frmFiltroPesqti" class="formulario" style="display:none;">
	<fieldset id="fsetTipoPagto" name="fsetTipoPagto" style="padding:0px; margin:0px; padding-bottom:10px;">

		<legend> Tipo de pagamento </legend>

		<div id="divTipoPagto" style="display:none">

			<label for="tpdpagto" ><? echo utf8ToHtml('Tp.Pgto.:') ?></label>
			<select name="tpdpagto" id="tpdpagto" class="campo">
				<option value="yes">T - Titulos</option>
				<option value="no" selected> F - Faturas</option>
			</select>

			<!-- PJ406
      <label for="flgcnvsi" ><? //echo utf8ToHtml('Sicredi:') ?></label>
			<select name="flgcnvsi" id="flgcnvsi" class="campo" >
				<option value="yes">Sim</option>
				<option value="no" selected>N&atilde;o</option> 		
			</select>
      -->

			<br style="clear:both" />

		</div>

	</fieldset>

	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;display:none;">

		<legend> Filtro </legend>

		<div id="divFiltroFatura" style="display:none">

			<label for="dtdpagto"><? echo utf8ToHtml('Data:') ?></label>
			<input name='dtdpagto' type='text' class='campo' id='dtdpagto'>

			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input name="cdagenci" type="text" class="campo" id="cdagenci" value="0">
			<a style="margin-top:5px"><img id="lupaPAt" name = "lupaPAt" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<label for="cdhiscxa">Hist&oacute;rico:</label>
			<input name="cdhiscxa" type="text" class="campo" id="cdhiscxa" value="0">
			<a style="margin-top:5px"><img id="lupaHist" name = "lupaHist" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<label for="vldpagto"><? echo utf8ToHtml('Valor:') ?></label>
			<input name="vldpagto" type="text" class="campo" id="vldpagto" value="0">

			<br style="clear:both" />	

		</div>

		<div id="divFiltroFaturaSicredi" style="display:none">

      <!-- Incluido PJ406 -->
      <label for="dtipagto"><? echo utf8ToHtml('Período:') ?></label>
      <input name='dtipagto' type='text' class='campo' id='dtipagto'>

      <label for="dtfpagto"><? echo utf8ToHtml('a') ?></label>
      <input name='dtfpagto' type='text' class='campo' id='dtfpagto'>
      <!-- Incluido PJ406 -->

      <!-- PJ406
			<label for="dtdpagto"><? echo utf8ToHtml('Data:') ?></label>
			<input name='dtdpagto' type='text' class='campo' id='dtdpagto'>
      -->

      <label for="cdempcon"><? echo utf8ToHtml('Empresa:') ?></label>
			<input name="cdempcon" type="text" class="campo" id="cdempcon" value="0">
			<a style="margin-top:5px"><img id="lupaEmp" name = "lupaEmp" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

      <label for="cdsegmto"><? echo utf8ToHtml('Segmento.:') ?></label>
			<input name="cdsegmto" type="text" class="campo" id="cdsegmto" value="0">

			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input name="cdagenci" type="text" class="campo" id="cdagenci" value="0">
			<a style="margin-top:5px"><img id="lupaPAt" name = "lupaPAt" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

      <!-- Incluido PJ406 -->
      <label for="nrdconta">Conta/dv:</label>
      <input name="nrdconta" type="text" class="campo" id="nrdconta" value="0">
      <!-- Incluido PJ406 -->

			<label for="vldpagto"><? echo utf8ToHtml('Valor:') ?></label>
			<input name="vldpagto" type="text" class="campo" id="vldpagto" value="0">

      <!-- Incluido PJ406 -->
      <label for="nrautdoc"><? echo utf8ToHtml('Autenticação:') ?></label>
			<input name="nrautdoc" type="text" class="campo" id="nrautdoc" value="0">
      <!-- Incluido PJ406 -->

			<br style="clear:both" />	

		</div>

		<div id="divFiltroTitulos" style="display:none">

			<label for="dtdpagto"><? echo utf8ToHtml('Data:') ?></label>
			<input name='dtdpagto' type='text' class='campo' id='dtdpagto'>

			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input name="cdagenci" type="text" class="campo" id="cdagenci" value="0">
			<a style="margin-top:5px"><img id="lupaPAt" name = "lupaPAt" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<label for="vldpagto"><? echo utf8ToHtml('Valor:') ?></label>
			<input name="vldpagto" type="text" class="campo" id="vldpagto" value="0">

			<br style="clear:both" />	
			
		</div>
		
	</fieldset>
	
	
</form>

<div id="divBotoesFiltros" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar"  style="text-align: right;">Voltar</a>
	<a href="#" class="botao" id="btConsultar"  style="text-align: right;">Consultar</a>
	
</div>