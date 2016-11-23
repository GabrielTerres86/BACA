<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Cabeçalho para a tela CASH
 * --------------
 * ALTERAÇÕES   : 14/09/2012 - Implementação do novo layout, botões, select (David Kruger).
 *
 *                27/07/2016 - Criacao da opcao 'S'. (Jaison/Anderson)
 *
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" id="dtlimite" name="dtlimite" value="" />
	<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>	
	<select id="cddopcao" name="cddopcao">
	<option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?> >A - Alterar cadastro</option>
	<option value="B" <?php echo $cddopcao == 'B' ? 'selected' : '' ?> >B - Bloquear ou liberar terminais</option>
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?> >C - Consultar movimentacoes</option>
	<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?> >I - Incluir novo terminal</option>
	<option value="L" <?php echo $cddopcao == 'L' ? 'selected' : '' ?> >L - Recolhimento de envelopes e numerarios</option>
	<option value="M" <?php echo $cddopcao == 'M' ? 'selected' : '' ?> >M - Monitorar terminais</option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?> >R - Relatorios de movimentacao</option>
	<option value="S" <?php echo $cddopcao == 'S' ? 'selected' : '' ?> >S - Dados Cadastrais</option>
	</select> 
    <a href="#" class="botao" id="btnOK" name="btnOK">OK</a>	

	<label for="nrterfin">Numero do Terminal de Saque:</label>
	<input name="nrterfin" id="nrterfin" type="text" value="<? echo $nrterfin ?>" autocomplete="off"/>
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input name="dsterfin" id="dsterfin" type="text" value="<? echo $dsterfin ?>" />

	<br style="clear:both" />	
	
</form>

<div id="divBotoes2" style="margin-bottom:8px; margin-left:230px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>	
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmCab'));
	});

</script>
