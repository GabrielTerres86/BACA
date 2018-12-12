<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/18
 * OBJETIVO     : Cabeçalho para a tela SOLPOR
 * -------------- 
 * ALTERAÇÕES   : 
 * 
 * --------------
 */
?>

<div id="divCab">
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input id="registro" name="registro" type="hidden" value=""  />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao" style="width: 68px;"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" style="width: 640px;">
		<option value="M" <? echo $cddopcao == 'M' ? 'selected' : '' ?> > M - Manter as Solicita&ccedil;&otilde;es de Portabilidade de Sal&aacute;rio</option>
		<option value="E" <? echo $cddopcao == 'E' ? 'selected' : '' ?> > E - Solicita&ccedil;&otilde;es de Portabilidade de Sal&aacute;rio Enviadas</option>
		<option value="R" <? echo $cddopcao == 'R' ? 'selected' : '' ?> > R - Solicita&ccedil;&otilde;es de Portabilidade de Sal&aacute;rio Recebidas</option>
	</select>	
	<a href="#" class="botao" id="btnOK" onClick="LiberaCampos(); return false;">OK</a>	
		
	<br style="clear:both" />	
	
</form>
</div>