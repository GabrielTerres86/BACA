<? 
 /*!
 * FONTE        : form_auto.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 27/09/2011
 * OBJETIVO     : Formulário da rotina Seguro da tela ATENDA
 */	
 ?>

<form name="frmAuto" id="frmAuto" class="formulario">	

	<label for="nmresseg">Segurado:</label>
	<input name="nmresseg" id="nmresseg" type="text" value="" />
	
	<label for="dsmarvei">Marca:</label>
	<input name="dsmarvei" id="dsmarvei" type="text" value="" />
	
	<label for="dstipvei">Tipo:</label>
	<input name="dstipvei" id="dstipvei" type="text" value="" />

	<label for="nranovei">Ano:</label>
	<input name="nranovei" id="nranovei" type="text" value="" />

	<label for="nrmodvei">Modelo:</label>
	<input name="nrmodvei" id="nrmodvei" type="text" value="" />

	<label for="nrdplaca">Placa:</label>
	<input name="nrdplaca" id="nrdplaca" type="text" value="" />	

	<fieldset>
		<legend><? echo utf8ToHtml('Vigência do seguro'); ?></legend>
	
		<label for="dtinivig"><? echo utf8ToHtml('Início:'); ?></label>
		<input name="dtinivig" id="dtinivig" type="text" value="" />
				
		<label for="dtfimvig">Final:</label>
		<input name="dtfimvig" id="dtfimvig" type="text" value="" />
		
	</fieldset>
	
	<label for="qtparcel">Qtd. Parcelas:</label>
	<input name="qtparcel" id="qtparcel" type="text" value="" />

	<label for="vlpreseg">Vl. Parcela:</label>
	<input name="vlpreseg" id="vlpreseg" type="text" value="" />

	<label for="dtdebito"><? echo utf8ToHtml('Dia do débito:'); ?></label>
	<input name="dtdebito" id="dtdebito" type="text" value="" />

	<label for="vlpremio"><? echo utf8ToHtml('Tot. prêmio:'); ?></label>
	<input name="vlpremio" id="vlpremio" type="text" value="" />
  
</form>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao(''); return false;" />
</div>