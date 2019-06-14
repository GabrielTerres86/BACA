<? 
/*!
 * FONTE        : formulario_fatca_crs.php
 * CRIAÇÃO      : Mateus Z (Mouts)
 * DATA CRIAÇÃO : 10/04/2018 
 * OBJETIVO     : Rotina para validar/alterar os dados do FATCA/CRS da tela de CONTAS
 * ALTERACOES	: 
 */
?>

<form name="frmDadosFatcaCrs" id="frmDadosFatcaCrs" class="formulario">

	<input type="hidden" name="inacordo" id="inacordo" value="<? echo getByTagName($dados,'inacordo') ?>">

	<fieldset>
				
		<label for="inobrigacao_exterior"><? echo utf8ToHtml('Cooperado possui domicílio ou qualquer obrigação fiscal fora do Brasil?') ?></label>
		<select name="inobrigacao_exterior" id="inobrigacao_exterior">
			<option value=""  <?php if (getByTagName($dados,'inobrigacao_exterior') == "")  { echo ' selected'; } ?>></option>
			<option value="S" <?php if (getByTagName($dados,'inobrigacao_exterior') == "S") { echo ' selected'; } ?>>Sim</option>
			<option value="N" <?php if (getByTagName($dados,'inobrigacao_exterior') == "N") { echo ' selected'; } ?>><? echo utf8ToHtml('Não') ?></option>
		</select>
		
		<label for="cdpais"><? echo utf8ToHtml('País onde possui domicílio/obrigação fiscal:') ?></label>
		<input name="cdpais" id="cdpais" type="text" class="pesquisa" value="<? echo getByTagName($dados,'cdpais') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dspais" id="dspais" type="text" value="<? echo getByTagName($dados,'nmpais') ?>" />

		<label for="nridentificacao">NIF:</label>
		<input name="nridentificacao" id="nridentificacao" type="text" value="<? echo getByTagName($dados,'nridentificacao') ?>" />

		<fieldset id="fsetEndereco">
		
			<legend><?php echo utf8ToHtml('Endereço no Exterior') ?></legend>

			<label for="dscodigo_postal"><?php echo utf8ToHtml('Cd.Postal:') ?></label>
			<input name="dscodigo_postal" id="dscodigo_postal" type="text" value="<?php echo getByTagName($dados,'dscodigo_postal') ?>" />

			<label for="nmlogradouro"><?php echo utf8ToHtml('Rua:') ?></label>
			<input name="nmlogradouro" id="nmlogradouro" type="text" value="<?php echo getByTagName($dados,'nmlogradouro') ?>" />		

			<label for="nrlogradouro"><?php echo utf8ToHtml('Nr.:') ?></label>
			<input name="nrlogradouro" id="nrlogradouro" type="text" value="<?php echo getByTagName($dados,'nrlogradouro') ?>" />
			
			<label for="dscomplemento"><?php echo utf8ToHtml('Compl.:') ?></label>
			<input name="dscomplemento" id="dscomplemento" type="text" value="<?php echo getByTagName($dados,'dscomplemento') ?>" />
			
			<label for="dscidade"><?php echo utf8ToHtml('Cidade:') ?></label>
			<input name="dscidade" id="dscidade" type="text" value="<?php echo getByTagName($dados,'dscidade') ?>"/>

			<label for="dsestado"><?php echo utf8ToHtml('Estado:') ?></label>
			<input name="dsestado" id="dsestado" type="text" value="<?php echo getByTagName($dados,'dsestado') ?>"/>

			<label for="cdpais_exterior"><? echo utf8ToHtml('País do endereço no exterior:') ?></label>
			<input name="cdpais_exterior" id="cdpais_exterior" type="text" class="pesquisa" value="<? echo getByTagName($dados,'cdpais_exterior') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dspais_exterior" id="dspais_exterior" type="text" value="<? echo getByTagName($dados,'nmpais_exterior') ?>" />

		</fieldset>
	</fieldset>
</form>

<div id="divBotoes">

	<? if ( in_array($operacao,array('AC','FA','')) ) { ?>
		
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);"   />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA')" />
		
	<? } else if ( $operacao == 'CA' ) { ?>
	
		<? if ($flgcadas == 'M' ) { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
		<? } else { ?>
			<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<? } ?>
	
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />
	<? } ?>
		
</div>