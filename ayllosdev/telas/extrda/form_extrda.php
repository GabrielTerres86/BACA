<? 
 /*!
 * FONTE        : form_extrda.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 02/08/2011 
 * OBJETIVO     : Formulário de exibição do EXTRDA
 * --------------
 * ALTERAÇÕES   : 27/11/2017 - Inclusao do valor de bloqueio em garantia. PRJ404 - Garantia Empr.(Odirlei-AMcom)  
 * --------------
 */	
?>
<form name="frmExtrda" id="frmExtrda" class="formulario" onSubmit="return false;" >	

	<fieldset>
	
		<legend> Dados do Extrato </legend>	

		
		<label for="nraplica"><? echo utf8ToHtml('Aplicação:') ?></label>
		<input name="nraplica" id="nraplica" type="text" value="<? echo getByTagName($dados,'nraplica') ?>" autocomplete="off" />
		<input name="dsaplica" id="dsaplica" type="text" value="<? echo getByTagName($dados,'dsaplica') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
		<label for="vlsdrdad"><? echo utf8ToHtml('Saldo dia:') ?></label>
		<input name="vlsdrdad" id="vlsdrdad" type="text" value="<? echo getByTagName($dados,'vlsdrdad'); ?>" />
		
		<label for="vlsdrdca"><? echo utf8ToHtml('d+1:') ?></label>
		<input name="vlsdrdca" id="vlsdrdca" type="text" value="<? echo getByTagName($dados,'vlsdrdca') ?>" />

		<label for="cdoperad"><? echo utf8ToHtml('Ope.Apl:') ?></label>
		<input name="cdoperad" id="cdoperad" type="text" value="<? echo getByTagName($dados,'cdoperad') ?>" />

		<label for="vlsdresg"><? echo utf8ToHtml('Sado p/ Resg.:') ?></label>
		<input name="vlsdresg" id="vlsdresg" type="text" value="<? echo getByTagName($dados,'vlsdresg') ?>" />

		<label for="qtdiaapl"><? echo utf8ToHtml('Prazo:') ?></label>
		<input name="qtdiaapl" id="qtdiaapl" type="text" value="<? echo getByTagName($dados,'qtdiaapl') ?>" />

		<label for="qtdiauti"><? echo utf8ToHtml('Carencia:') ?></label>
		<input name="qtdiauti" id="qtdiauti" type="text" value="<? echo getByTagName($dados,'qtdiauti') ?>" />

		<label for="txcntrat"><? echo utf8ToHtml('Taxa Contratada:') ?></label>
		<input name="txcntrat" id="txcntrat" type="text" value="<? echo formataTaxa(getByTagName($dados,'txcntrat')) ?>" />

		<label for="txminima"><? echo utf8ToHtml('Taxa Minima:') ?></label>
		<input name="txminima" id="txminima" type="text" value="<? echo formataTaxa(getByTagName($dados,'txminima')) ?>" />
        
        <label for="vlbloque"><? echo utf8ToHtml('Bloq. Jud:') ?></label>
		<input name="vlbloque" id="vlbloque" type="text" />
        
        <label for="vlblqapl"><? echo utf8ToHtml('Bloq. Garantia:') ?></label>
		<input name="vlblqapl" id="vlblqapl" type="text" />
		
		
	</fieldset>		
	
</form>

