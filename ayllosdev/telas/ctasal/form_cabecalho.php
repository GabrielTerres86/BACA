<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 29/11/2011
 * OBJETIVO     : Cabeçalho para a tela PESQDP
 * --------------
 * ALTERAÇÕES   : 23/04/2015 - Ajustando a tela CTASAL
 *                             Projeto 158 - Servico Folha de Pagto
 *                             (Andre Santos - SUPERO)
 * --------------
 */

?>

<script>
	// Criando variavel DTMVTOLT para exibir a data cadastrada no sistema
	dtmvtolt = "<? echo $glbvars['dtmvtolt'] ; ?>";
</script>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onsubmit="return false;">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="A" > <? echo utf8ToHtml('A - ALTERAÇÃO') ?> </option>
		<option value="C" selected > C - CONSULTA </option>
		<option value="E" > <? echo utf8ToHtml('E - EXCLUSÃO') ?> </option>
		<option value="I" > <? echo utf8ToHtml('I - INCLUSÃO') ?> </option>
		<option value="S" > <? echo utf8ToHtml('S - SUBSTITUTIÇÃO') ?> </option>
		<option value="X" > X - REATIVAR CONTA </option>
	</select>

	<label for="nrdconta"><? echo utf8ToHtml('Conta/DV:') ?></label>
	<input id="nrdconta" name="nrdconta" type="text"/>
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

	<a href="#" class="botao" id="btnOK" >OK</a>

	<br style="clear:both" />

</form>

<form name="frmImprimir" id="frmImprimir">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input name="cddopcao" id="cddopcao" type="hidden" value="" />
	<input name="nrdconta" id="nrdconta" type="hidden" value="" />
	<input name="dtrefere" id="dtrefere" type="hidden" value="" />
</form>