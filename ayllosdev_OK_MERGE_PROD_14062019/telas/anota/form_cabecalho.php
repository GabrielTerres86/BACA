<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 16/02/2011
 * OBJETIVO     : Cabeçalho para a tela ANOTA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<form id="frmCabAnota" name="frmCabAnota" class="formulario">
		
	<label for="opcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="opcao" name="opcao" alt="Informe a opcao desejada (A, C, D ou E).">
		<option value="FC"> C </option> 
		<option value="FA"> A </option>
		<option value="TI"> I </option>
		<option value="FE"> E </option>
	</select>
	
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo getByTagName($associado,'nrdconta') ?>" alt="Informe o numero da conta do cooperado." />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input type="image" onclick="consultaInicial();return false;" src="<?php echo $UrlImagens; ?>/botoes/ok.gif">
	
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo getByTagName($associado,'nmprimtl') ?>" />
			
	<br style="clear:both" />	
</form>

<script type='text/javascript'>
	
	formataCabecalho();
	
</script>