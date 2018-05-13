<?
/*****************************************************************
  Fonte        : form_filtro.php
  Cria��o      : Adriano
  Data cria��o : Junho/2015
  Objetivo     : Form respons�vel por apresentar as op��es de filtro para consulta
  --------------
  Altera��es   :
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
			
			<label for="flgcnvsi" ><? echo utf8ToHtml('Sicredi:') ?></label>
			<select name="flgcnvsi" id="flgcnvsi" class="campo" >
				<option value="yes">Sim</option>
				<option value="no" selected>N&atilde;o</option> 		
			</select>
			
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
		
			<label for="dtdpagto"><? echo utf8ToHtml('Data:') ?></label>
			<input name='dtdpagto' type='text' class='campo' id='dtdpagto'>
			
			<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
			<input name="cdagenci" type="text" class="campo" id="cdagenci" value="0">
			<a style="margin-top:5px"><img id="lupaPAt" name = "lupaPAt" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			
			<label for="cdempcon"><? echo utf8ToHtml('Empresa:') ?></label>
			<input name="cdempcon" type="text" class="campo" id="cdempcon" value="0">
			<a style="margin-top:5px"><img id="lupaEmp" name = "lupaEmp" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			
			<label for="cdsegmto"><? echo utf8ToHtml('Segmento.:') ?></label>
			<input name="cdsegmto" type="text" class="campo" id="cdsegmto" value="0">
				
			<label for="vldpagto"><? echo utf8ToHtml('Valor:') ?></label>
			<input name="vldpagto" type="text" class="campo" id="vldpagto" value="0">
				
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