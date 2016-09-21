<? 
 /*!
 * FONTE        : form_concbb.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 18/08/2011 
 * OBJETIVO     : Formulário de exibição da CONCBB
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>
<form name="frmConcbb" id="frmConcbb" class="formulario" onSubmit="return false;" >	

	<fieldset>
		<legend>Processos</legend>
		
		<label for="qtde">Qtde</label>
		<label for="valor">Valor</label>
		<br />
		
		<label for="qttitrec"><? echo utf8ToHtml('Titulos Recebidos:') ?></label>
		<input name="qttitrec" id="qttitrec" type="text" value="<? echo mascara(getByTagName($concbb,'qttitrec'),'###.###') ?>" />
		<label for="vltitrec"></label>
		<input name="vltitrec" id="vltitrec" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vltitrec')) ?>" />
		<br />
		
		<label for="qttitliq"><? echo utf8ToHtml('Titulos Liquidados:') ?></label>
		<input name="qttitliq" id="qttitliq" type="text" value="<? echo mascara(getByTagName($concbb,'qttitliq'),'###.###')  ?>" />
		<label for="vltitliq"></label>
		<input name="vltitliq" id="vltitliq" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vltitliq')) ?>" />
		<br />
		
		<label for="qttitcan"><? echo utf8ToHtml('Titulos Cancelados:') ?></label>
		<input name="qttitcan" id="qttitcan" type="text" value="<? echo mascara(getByTagName($concbb,'qttitcan'),'###.###')  ?>" />
		<label for="vltitcan"></label>
		<input name="vltitcan" id="vltitcan" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vltitcan')) ?>" />
		<br />
		
		<label for="qtfatrec"><? echo utf8ToHtml('Faturas Recebidas:') ?></label>
		<input name="qtfatrec" id="qtfatrec" type="text" value="<? echo mascara(getByTagName($concbb,'qtfatrec'),'###.###')  ?>" />
		<label for="vlfatrec"></label>
		<input name="vlfatrec" id="vlfatrec" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vlfatrec')) ?>" />
		<br />

		<label for="qtfatliq"><? echo utf8ToHtml('Faturas Liquidadas:') ?></label>
		<input name="qtfatliq" id="qtfatliq" type="text" value="<? echo mascara(getByTagName($concbb,'qtfatliq'),'###.###')  ?>" />
		<label for="vlfatliq"></label>
		<input name="vlfatliq" id="vlfatliq" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vlfatliq')) ?>" />
		<br />

		<label for="qtfatcan"><? echo utf8ToHtml('Faturas Canceladas:') ?></label>
		<input name="qtfatcan" id="qtfatcan" type="text" value="<? echo mascara(getByTagName($concbb,'qtfatcan'),'###.###')  ?>" />
		<label for="vlfatcan"></label>
		<input name="vlfatcan" id="vlfatcan" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vlfatcan')) ?>" />
		<br style="clear:both"  /><br />
		
		<label for="qtinss"><? echo utf8ToHtml('Qtde INSS:') ?></label>
		<input name="qtinss" id="qtinss" type="text" value="<? echo mascara(getByTagName($concbb,'qtinss'),'###.###')  ?>" />
		<label for="vlinss"></label>
		<input name="vlinss" id="vlinss" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vlinss')) ?>" />
		<br style="clear:both"  /><br />

		<label for="qtdinhei"><? echo utf8ToHtml('Pago Dinheiro:') ?></label>
		<input name="qtdinhei" id="qtdinhei" type="text" value="<? echo mascara(getByTagName($concbb,'qtdinhei'),'###.###')  ?>" />
		<label for="vldinhei"></label>
		<input name="vldinhei" id="vldinhei" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vldinhei')) ?>" />
		<br />
		
		<label for="qtcheque"><? echo utf8ToHtml('Pago Cheque:') ?></label>
		<input name="qtcheque" id="qtcheque" type="text" value="<? echo mascara(getByTagName($concbb,'qtcheque'),'###.###')  ?>" />
		<label for="vlcheque"></label>
		<input name="vlcheque" id="vlcheque" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vlcheque')) ?>" />

		<?php
		if ( $cddopcao == 'T' ) {
		?>
		
		<br style="clear:both"  /><br />
		<label for="vlrepasse"><? echo utf8ToHtml('REPASSE:') ?></label>
		<input name="vlrepasse" id="vlrepasse" type="text" value="<? echo formataMoeda(getByTagName($concbb,'vlrepasse')) ?>" />
		
		<?php
		}
		?>
		
	</fieldset>

	
</form>

																
