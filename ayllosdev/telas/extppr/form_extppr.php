<? 
 /*!
 * FONTE        : form_extppr.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011 
 * OBJETIVO     : Formulário de exibição do EXTPPR
 * --------------
 * ALTERAÇÕES   : 20/09/2012 - Inclusao da funcao utf8ToHtml no legend (Lucas R.)
 * 				  05/06/2013 - Inclusao de label vlbloque - Bloqueio Judicial (Lucas R.)
 *                27/11/2017 - Inclusao do valor de bloqueio em garantia. PRJ404 - Garantia Empr.(Odirlei-AMcom)  
 *
 */	
?>
<form name="frmExtppr" id="frmExtppr" class="formulario" onSubmit="return false;" >	

	<fieldset>
	
		<legend><? echo utf8ToHtml('Dados do Extrato') ?></legend>

		<label for="nmprimtl">Titular:</label>
		<input name="nmprimtl" id="nmprimtl" type="text" />
			
		<br />	
		
		<label for="dtvctopp"><? echo utf8ToHtml('Data de Vcto:') ?></label>
		<input name="dtvctopp" id="dtvctopp" type="text" />
		
		<label for="dddebito"><? echo utf8ToHtml('Dia do Debito:') ?></label>
		<input name="dddebito" id="dddebito" type="text" />
		
		<br />
		<label for="vlbloque"><? echo utf8ToHtml('Bloq. Jud:') ?></label>
		<input name="vlbloque" id="vlbloque" type="text" />
		
        <label for="vlblqpou"><? echo utf8ToHtml('Bloq. Garantia:') ?></label>
		<input name="vlblqpou" id="vlblqpou" type="text" />
		<br />
        
		<label for="vlrdcapp"><? echo utf8ToHtml('Saldo Atual:') ?></label>
		<input name="vlrdcapp" id="vlrdcapp" type="text" />
		
	</fieldset>		


	
</form>