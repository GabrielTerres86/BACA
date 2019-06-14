<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 13/03/2013
 * OBJETIVO     : Cabeçalho para a tela ESTTAR
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */

?>

<style>
.ui-datepicker-trigger{
	float:left;
	margin-left:6px;
	margin-top:6px;
}
</style> 

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none" >
		
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta ?>" />
	<a href="#" onclick="controlaPesquisas(1); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input id="nmprimtl" name="nmprimtl" type="text" value="<? echo $nmprimtl ?>"/>
	<label for="cdagenci">PA:</label>
	<input type="text" id="cdagenci" name="cdagenci" value="<? echo $cdagenci ?>" />
	
	<br style="clear:both" />
	
	<label for="dtinicio">Per&iacute;odo:</label>
	<input type="text" id="dtinicio" name="dtinicio" value="<? echo $dtinicio ?>" />
	<label for="dtafinal"> at&eacute; </label>
	<input type="text" id="dtafinal" name="dtafinal" value="<? echo $dtafinal ?>" />
	<label for="cddopcap" >A&ccedil;&atilde;o:</label>
	<select id="cddopcap" name="cddopcap" style="width: 200px;">
		<option value="1"><? echo utf8ToHtml('1 - ESTORNO') ?> </option> 
		<option value="2"><? echo utf8ToHtml('2 - BAIXA') ?> </option>
		<option value="3"><? echo utf8ToHtml('3 - SUSPENSÃO') ?> </option>
	</select>
	
	<br style="clear:both" />
	
	<label for="cdhistor">Hist&oacute;rico:</label>
	<input type="text" id="cdhistor" name="cdhistor" value="<? echo $cdhistor ?>" />
	<a href="#" onclick="controlaPesquisas(2); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input type="text" id="dshistor" name="dshistor" value="<? echo $dshistor ?>" />
	<br style="clear:both" />	
	
	<input type="hidden" id="dtlimest" name="dtlimest" />
	<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
	
</form>


<script>

	$(document).ready(function() {
		buscaQtdDiasEstorno();
	});

   

  $.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );	
  
  $(function() {
	  $( "#dtinicio" ).datepicker({
	  showOn: "button",
	  maxDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
	  defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",	
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    }); 
  });
  
  $(function() {
	  $( "#dtafinal" ).datepicker({
	  showOn: "button",
	  maxDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
	  defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",	
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    }); 
  });


</script>