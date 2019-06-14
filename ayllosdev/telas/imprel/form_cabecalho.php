<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 24/08/2011
 * OBJETIVO     : Cabeçalho para a tela IMPREL
 * --------------
 * ALTERAÇÕES   : 26/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout, alterado para não mostrar
 * 							   form ao carregar a tela (Daniel).
 *                15/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *                21/03/2019 - Adicionado do campo periodo para o relatorio 219. 
 *                             Acelera - Reapresentacao automática de cheques (Lombardi).
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > C - Imprimir individualmente por PA  todos os relatorios disponiveis.</option> 
		<option value="D" <? echo $cddopcao == 'D' ? 'selected' : '' ?> > D - Imprimir individualmente por PA  os relatorios mais utilizados no atendimento</option>
	</select>
	<a href="#" class="botao" id="btnOK" >OK</a>

	<label for="nrdrelat"><? echo utf8ToHtml('Relatório:') ?></label>
	<select name="nrdrelat" id="nrdrelat" onSelect="setFlag( this.value ); return false;">
	<option value=""></option>
	<?php
	foreach ( $registro as $r ) { 
	if ( $cddopcao == 'C' or ($cddopcao == 'D' and  getByTagName($r->tags,'flgrelat') == 'yes') ) { 
	?>
	<option value="<? echo getByTagName($r->tags,'contador'); ?>"><? echo getByTagName($r->tags,'nmrelato'); ?></option>
	<script>arrayImprel[<? echo getByTagName($r->tags,'contador');?>] = ['<? echo getByTagName($r->tags,'flgvepac'); ?>', '<? echo getByTagName($r->tags,'periodo'); ?>'];</script>
	<?php
	}}
	?>
	</select>

	<label for="cdagenca"><? echo utf8ToHtml('PA:') ?></label>
	<input id="cdagenca" name="cdagenca" type="text"/>
	
	<label for="cdperiod"><? echo utf8ToHtml('Período:') ?></label>
	<select id="cdperiod" name="cdperiod">
		<option value="5">Diurno</option>
		<option value="6">Noturno</option>
	</select>
	
	<br style="clear:both" />	
	
</form>

<div id="divBotoes" style="margin-bottom:10px;display:none" >
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>
</div>
