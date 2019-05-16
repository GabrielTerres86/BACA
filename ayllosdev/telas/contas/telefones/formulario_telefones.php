<? 
/*!
 * FONTE        : formulario_telefones.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/05/2010 
 * OBJETIVO     : Formulário da rotina TELEFONES da tela de CONTAS
 */	
?>

<form name="frmTelefones" id="frmTelefones" class="formulario">	

	<input id="nrdrowid" name="nrdrowid" type="hidden" value="<? echo getByTagName($registro,'nrdrowid') ?>" />
	
	<label for="tptelefo"><? echo utf8ToHtml('Identificação:'); ?></label>
	<select id="tptelefo" name="tptelefo">
		<option value=""> - </option>
		<option value="1" <? if (getByTagName($registro,'tptelefo') == '1' ){ echo ' selected'; } ?>> Residencial </option>
		<option value="2" <? if (getByTagName($registro,'tptelefo') == '2' ){ echo ' selected'; } ?>> Celular     </option>
		<option value="3" <? if (getByTagName($registro,'tptelefo') == '3' ){ echo ' selected'; } ?>> Comercial   </option>
		<option value="4" <? if (getByTagName($registro,'tptelefo') == '4' ){ echo ' selected'; } ?>> Contato     </option>
	</select>	
	<br />
	
	<label for="nrdddtfc">DDD:</label>
	<input name="nrdddtfc" id="nrdddtfc" type="text" value="<? echo getByTagName($registro,'nrdddtfc') ?>" />
	
	<label for="nrtelefo">Telefone:</label>
	<input name="nrtelefo" id="nrtelefo" type="text" value="<? echo getByTagName($registro,'nrtelefo') ?>" />
	<br />
	
	<label for="cdopetfn">Operadora:</label>
	<select name="cdopetfn" id="cdopetfn">
		<option value=""> - </option>
	</select>
	<br />
	
	<label for="nrdramal">Ramal:</label>
	<input name="nrdramal" id="nrdramal" type="text" value="<? echo getByTagName($registro,'nrdramal') ?>" />
	
	<label for="secpscto">Setor:</label>
	<input name="secpscto" id="secpscto" type="text" value="<? echo getByTagName($registro,'secpscto') ?>" />
	<br />	
	
	<label for="nmpescto">Pessoa Contato:</label>
	<input name="nmpescto" id="nmpescto" type="text" value="<? echo getByTagName($registro,'nmpescto') ?>" />
	<br />
	
	<label for="idsittfc"><? echo utf8ToHtml('Situação:'); ?></label>
	<select id="idsittfc" name="idsittfc">
		<option value=""> - </option>
		<option value="1" <? if (getByTagName($registro,'idsittfc') == '1' ){ echo ' selected'; } ?>> Ativo </option>
		<option value="2" <? if (getByTagName($registro,'idsittfc') == '2' ){ echo ' selected'; } ?>> Inativo </option>
	</select>
	
	<label for="idorigem"><? echo utf8ToHtml('Origem:'); ?></label>
	<select id="idorigem" name="idorigem">
		<option value=""> - </option>
		<option value="1" <? if (getByTagName($registro,'idorigem') == '1' ){ echo ' selected'; } ?>> Cooperado </option>
		<option value="2" <? if (getByTagName($registro,'idorigem') == '2' ){ echo ' selected'; } ?>> Cooperativa </option>
		<option value="3" <? if (getByTagName($registro,'idorigem') == '3' ){ echo ' selected'; } ?>> Terceiros </option>
	</select>

	<?php if ($inpessoa == 1) { ?>
		<label for="idcanal"><? echo utf8ToHtml('Canal:'); ?></label>
		<select id="idcanal" name="idcanal">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($registro,'dsdcanal') == 'IB' ){ echo ' selected'; } ?>> IB </option>
			<option value="2" <? if (getByTagName($registro,'dsdcanal') == 'Mobile' ){ echo ' selected'; } ?>> Mobile </option>
		</select>

		<label for="dtrevisa"><? echo utf8ToHtml('Data revisão:'); ?></label>
		<input name="dtrevisa" id="dtrevisa" type="text"  value="<? echo getByTagName($registro,'dtrevisa') ?>" />
	<?php } ?>
	<br />
</form>
<div id="divBotoes">
	<? if ( $operacao == 'TA' ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('AT');" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />
	<? } else if ($operacao == 'TI') { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('IT');" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('IV');" />
	<? }else if ($operacao == 'CF'){ ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao();" />		
	<?}?>
</div>
<span id='sugestao'></span>