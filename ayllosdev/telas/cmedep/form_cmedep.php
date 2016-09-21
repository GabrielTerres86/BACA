<? 
 /*!
 * FONTE        : form_cmedep.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 20/07/2011 
 * OBJETIVO     : Formulário de exibição da movimentação
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<form name="frmCmedep" id="frmCmedep" class="formulario">	

	<input type="hidden" name="nmarqpdf" id="nmarqpdf" value="">

	<fieldset>
		<legend><? echo utf8ToHtml('Dados da movimentação') ?></legend>

		<label for="nrseqaut"><? echo utf8ToHtml('Aut:') ?></label>
		<input name="nrseqaut" id="nrseqaut" type="text" />
		
		<label for="vllanmto"><? echo utf8ToHtml('Valor:') ?></label>
		<input name="vllanmto" id="vllanmto" type="text" />

		<label for="dsdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input name="dsdconta" id="dsdconta" type="text" />

		<br />
		
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Depositante') ?></legend>
		
		<label for="nrccdrcb"><? echo utf8ToHtml('Conta/Dv:') ?></label>
		<input name="nrccdrcb" id="nrccdrcb" type="text" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
		<label for="nmpesrcb"><? echo utf8ToHtml('Nome:') ?></label>
		<input name="nmpesrcb" id="nmpesrcb" type="text" />
		
		<label for="cpfcgrcb"><? echo utf8ToHtml('CPF:') ?></label>
		<input name="cpfcgrcb" id="cpfcgrcb" type="text" />

		<label for="nridercb"><? echo utf8ToHtml('Nr.Ide') ?></label>
		<input name="nridercb" id="nridercb" type="text" />

		<label for="dtnasrcb"><? echo utf8ToHtml('Nasc:') ?></label>
		<input name="dtnasrcb" id="dtnasrcb" type="text" />

		<label for="desenrcb"><? echo utf8ToHtml('Endereço:') ?></label>
		<input name="desenrcb" id="desenrcb" type="text" />

		<label for="nmcidrcb"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidrcb" id="nmcidrcb" type="text" />

		<label for="nrceprcb"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrceprcb" id="nrceprcb" type="text" />

		<? echo selectEstado('cdufdrcb', getByTagName($registro,'cdufdrcb'), 1); ?>	

		<label for="flinfdst"><? echo utf8ToHtml('Informações prestadas pelo cooperado:') ?></label>
		<select id="flinfdst" name="flinfdst">
			<option value="no" selected> N&atilde;o </option>
			<option value="yes" > Sim </option>
		</select>		

		<label for="recursos"><? echo utf8ToHtml('Recursos:') ?></label>
		<input name="recursos" id="recursos" type="text" />

		<br />
		
	</fieldset>	

</form>

<div id="divBotoes">	
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onclick="btnVoltar();return false;"   />
	<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onclick="btnConcluir();return false;" />
</div>