<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 18/08/2011
 * OBJETIVO     : Cabeçalho para a tela CONCBB
 * --------------
 * ALTERAÇÕES   : 05/03/2013 - Ajuste para o novo layout padrão (Gabriel).
 *                14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input id="registro" name="registro" type="hidden" value=""  />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > C - Consultar</option> 
		<option value="D" <? echo $cddopcao == 'D' ? 'selected' : '' ?> > D - <? echo utf8ToHtml('Impressão Solicitação de Restituição') ?></option>
		<option value="R" <? echo $cddopcao == 'R' ? 'selected' : '' ?> > R - <? echo utf8ToHtml('Relatório') ?></option>
		<option value="V" <? echo $cddopcao == 'V' ? 'selected' : '' ?> > V - Visualizar os lotes </option>
		<option value="T" <? echo $cddopcao == 'T' ? 'selected' : '' ?> > T - <? echo utf8ToHtml('Tratar arquivo de conciliação') ?></option>
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>	

	<br >

	<label for="dtmvtolt"><? echo utf8ToHtml('Referência:') ?></label>
	<input id="dtmvtolt" name="dtmvtolt" type="text" value="<? echo $dtmvtolx ?>"  />

	<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
	<input id="cdagenci" name="cdagenci" type="text" value="<? echo $cdagencx ?>" />

	<label for="nrdcaixa"><? echo utf8ToHtml('Caixa:') ?></label>
	<input id="nrdcaixa" name="nrdcaixa" type="text" value="<? echo $nrdcaixx ?>" />

	<label for="valorpag"><? echo utf8ToHtml('Valor:') ?></label>
	<input id="valorpag" name="valorpag" type="text" value="<? echo $valorpag ?>" />
	
	<label for="inss"><? echo utf8ToHtml('INSS:') ?></label>
	<select id="inss" name="inss">
	<option value="no"  <? echo $inss == 'no'  ? 'selected' : '' ?> >Nao</option>
	<option value="yes" <? echo $inss == 'yes' ? 'selected' : '' ?> >Sim</option>
	</select>
	
	<br style="clear:both" />	
	
</form>

<script type="text/javascript">
	highlightObjFocus($('#frmCab')); 
</script>