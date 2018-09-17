<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Cabeçalho para a tela SUMLOT
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
	
	<input type="hidden" id="nmarqpdf" name="nmarqpdf" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	
	<label for="cdagenci">PA:</label>
	<input type="text" id="cdagenci" name="cdagenci" />

	<label for="cdbccxlt"><? echo utf8ToHtml('Banco/Caixa:') ?></label>
	<input name="cdbccxlt" id="cdbccxlt" type="text" />

	<label for="qtcompln"><? echo utf8ToHtml('Total de Lanctos:') ?></label>
	<input name="qtcompln" id="qtcompln" type="text" />
	
	<label for="vlcompap"><? echo utf8ToHtml('Total Aplicado no Dia:') ?></label>
	<input name="vlcompap" id="vlcompap" type="text" />
	
	<br style="clear:both" />	
	
</form>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onclick="btnContinuar(); return false;">Prosseguir</a>
</div>
