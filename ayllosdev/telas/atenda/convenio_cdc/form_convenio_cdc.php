<?php
/*!
 * FONTE        : form_convenio_cdc.php
 * CRIAÇÃO      : Andre Santos (SUPERO)
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Formulário da rotina Convenio CDC da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   : 11/08/2016 - Inclusao de campos para apresentacao no site da cooperativa.
 *                             (Jaison/Anderson)
 *
 *                19/01/2016 - Alterado layout do form de conveio e adicionado lupa para o CEP. (Reinert)
 * --------------
 */	
?>
<form name="frmConvenioCdc" id="frmConvenioCdc" class="formulario">
    <input type="hidden" id="idcooperado_cdc" name="idcooperado_cdc" value="<?php echo $idcooperado_cdc ; ?>" />
    <input type="hidden" id="cdestado" name="cdestado" value="<?php echo ($cdestado ? $cdestado : $cdufende); ?>" />
    <label for="flgconve" class="clsCampos">Possui Convênio CDC:</label>
	<select id="flgconve" name="flgconve" class="clsCampos">
        <option value="1" <?php echo ($flgconve == 1 ? 'selected' : ''); ?>>Sim</option>
		<option value="0" <?php echo ($flgconve == 0 ? 'selected' : ''); ?>>Não</option>
	</select>
    <label for="dtinicon" class="clsCampos">Data Início Convênio:</label>
    <input name="dtinicon" id="dtinicon" type="text" value="<?php echo $dtinicon ; ?>" autocomplete="off" class="clsCampos" />
    <fieldset style="padding: 5px">
        <legend style="margin-top: 10px; padding: 2px 10px 2px 10px">Dados para o Site da Cooperativa</legend>
        <label for="nmfantasia">Nome fantasia:</label>
        <input type="text" id="nmfantasia" name="nmfantasia" value="<?php echo $nmfantasia; ?>" />
        <label for="cdcnae" class="clsCampos">CNAE:</label>
        <input type="text" id="cdcnae" name="cdcnae" value="<?php echo $cdcnae; ?>" class="clsCampos" />
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" class="clsCampos"></a>
        <input type="text" id="dscnae" name="dscnae" class="clsCampos" />
        <label for="nrcepend">CEP:</label>
        <input type="text" id="nrcepend" name="nrcepend" value="<?php echo $nrcep; ?>" onchange="alert('teste');		verificaCidade();		return false;" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>		
        <label for="dslogradouro">Endereço:</label>
        <input type="text" id="dslogradouro" name="dslogradouro" value="<?php echo $dslogradouro; ?>" />
        <label for="nrendereco">Nr:</label>
        <input type="text" id="nrendereco" name="nrendereco" value="<?php echo $nrendereco; ?>" />
        <label for="dscomplemento">Complemento:</label>
        <input type="text" id="dscomplemento" name="dscomplemento" value="<?php echo $dscomplemento; ?>" />
        <label for="nmbairro">Bairro:</label>
        <input type="text" id="nmbairro" name="nmbairro" value="<?php echo $nmbairro; ?>" />
		<label for="idcidade">Cidade:</label>
		<input type="text" id="idcidade" name="idcidade" value="<?php echo $idcidade; ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" id="dscidade" name="dscidade" value="<?php echo $dscidade; ?>" />
		<label for="cdufende">UF:</label>
		<input type="text" id="cdufende" name="cdufende" value="<?php echo $cdufende; ?>" />
        <label for="dstelefone">Telefone:</label>
        <input type="text" id="dstelefone" name="dstelefone" value="<?php echo $dstelefone; ?>" />
        <label for="dsemail">E-mail:</label>
        <input type="text" id="dsemail" name="dsemail" value="<?php echo $dsemail; ?>" />
        <label for="dslink_google_maps">Link Google Maps:</label>
        <textarea name="dslink_google_maps" id="dslink_google_maps"><?php echo $dslink_google_maps; ?></textarea>
	</fieldset>
</form>

<div id="divBotoes">	
	<? if ( in_array($operacao,array('AC',''))){ ?>
	<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA')" />
        <input type="image" id="btFiliais" src="<? echo $UrlImagens; ?>botoes/filiais.png"  onClick="controlaOperacao('FILIAIS')" />
	<? } else if ( $operacao == 'CA' ){ ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('ALTERAR')" />
	<? } else if ( in_array($operacao,array('FCA','FCI'))){ ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="controlaOperacao('FILIAIS')" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('<?php echo ($operacao == 'FCA' ? 'ALTERAR' : 'INCLUIR' ); ?>')" />
	<? } ?>
</div>