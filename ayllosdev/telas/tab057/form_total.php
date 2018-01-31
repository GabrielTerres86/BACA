<? 
 /*!
 * FONTE        : form_total.php
 * DATA CRIAÇÃO : Jsneiro/2018							 Última Alteração: 
 * OBJETIVO     : Formulário de exibição
 * --------------
 * ALTERAÇÕES   : 
				  
 */	
?>


<form name="frmTotal" id="frmTotal" class="formulario" style="display:block">	
	<fieldset>
		<legend><? echo utf8ToHtml('Totais') ?></legend>
		
		<label for="qtdoctos"><? echo utf8ToHtml('Qtd.:') ?></label>
		<input name="qtdoctos" id="qtdoctos" type="text" value="<? echo $qttotdoc; ?>" />
		
		<label for="vldoctos"><? echo utf8ToHtml('Arrec.:') ?></label>
		<input name="vldoctos" id="vldoctos" type="text" value="<? echo number_format(str_replace(",",".",$qttotarr),2,",","."); ?>" />
			
		<br />
		<label for="vltarifa"><? echo utf8ToHtml('Tarifa:') ?></label>
		<input name="vltarifa" id="vltarifa" type="text" value="<? echo number_format(str_replace(",",".",$qttottar),2,",","."); ?>" />

		<label for="vlapagar"><? echo utf8ToHtml('Pagar:') ?></label>
		<input name="vlapagar" id="vlapagar" type="text" value="<? echo number_format(str_replace(",",".",$qttotpag),2,",","."); ?>" />
		<br/>
	</fieldset>				
</form>

<script type="text/javascript">
  //Labels
  $('label[for="qtdoctos"]','#frmTotal').addClass('rotulo').css({'width':'100'});
  $('label[for="vldoctos"]','#frmTotal').addClass('rotulo-linha').css({'width':'100'});
  $('label[for="vltarifa"]','#frmTotal').addClass('rotulo').css({'width':'100'});
  $('label[for="vlapagar"]','#frmTotal').addClass('rotulo-linha').css({'width':'100'});
  
  //Campos
  $('#qtdoctos','#frmTotal').css({'width':'150px','text-align':'right'}).desabilitaCampo();
  $('#vldoctos','#frmTotal').css({'width':'150px','text-align':'right'}).desabilitaCampo();
  $('#vltarifa','#frmTotal').css({'width':'150px','text-align':'right'}).desabilitaCampo();
  $('#vlapagar','#frmTotal').css({'width':'150px','text-align':'right'}).desabilitaCampo();
	
</script>