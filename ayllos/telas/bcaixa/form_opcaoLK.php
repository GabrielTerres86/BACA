<? 
 /*!
 * FONTE        : form_opcaoLK.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 04/11/2011 
 * OBJETIVO     : Formulário de exibição das opcoes L e K da tela BCAIXA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>


<form name="frmOpcaoLK" id="frmOpcaoLK" class="formulario" onSubmit="return false;" >	

	<fieldset>
	
		<legend><? echo utf8ToHtml('Lançamentos Extra-Sistema') ?></legend>	

		<label for="cdhistor"><? echo utf8ToHtml('Historico:') ?></label>
		<input name="cdhistor" id="cdhistor" type="text" value="" />
		<input name="dshistor" id="dshistor" type="text" value="" />

		<label for="nrctadeb"><? echo utf8ToHtml('- D:') ?></label>
		<input name="nrctadeb" id="nrctadeb" type="text" value="" />

		<label for="nrctacrd"><? echo utf8ToHtml('- C:') ?></label>
		<input name="nrctacrd" id="nrctacrd" type="text" value="" />

		<label for="cdhistox"><? echo utf8ToHtml('') ?></label>
		<input name="cdhistox" id="cdhistox" type="text" value="" />
		<br />

		
		<label for="dsdcompl"><? echo utf8ToHtml('Complemento:') ?></label>
		<input name="dsdcompl" id="dsdcompl" type="text" value="" />
		<br />
		
		<label for="nrdocmto"><? echo utf8ToHtml('Documento:') ?></label>
		<input name="nrdocmto" id="nrdocmto" type="text" value="" />
		<br />
		
		<label for="vldocmto"><? echo utf8ToHtml('Valor:') ?></label>
		<input name="vldocmto" id="vldocmto" type="text" value="" />
		<br />
		
		<label for="nrseqdig"><? echo utf8ToHtml('Sequencia:') ?></label>
		<input name="nrseqdig" id="nrseqdig" type="text" value="" />

		
	</fieldset>
			
</form>

<div id="divBotoes" style="margin-bottom:8px; ">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="formataOpcaoLK('A'); return false;"  />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/consultar.gif" onClick="mostraOpcao('C'); return false;"  />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/excluir.gif" onClick="formataOpcaoLK('E'); return false;"  />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/incluir.gif" onClick="formataOpcaoLK('I'); return false;"  />

	<input id="btVoltar" type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="btnVoltar(); return false;" style="margin-left:160px"  />
	<input id="btSalvar" type="image" src="<?php echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="cdoplanc == '' ? '' : btnContinuar();"  />
	
</div>