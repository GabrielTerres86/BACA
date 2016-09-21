<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 18/22/2016
 * OBJETIVO     : Cabeçalho para a tela GESGAR
 * --------------
 * ALTERAÇÕES   : 
 *
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<div id="divCab">
		<input id="registro" name="registro" type="hidden" value=""  />
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
		
		<label for="cddopcao"><?php echo utf8ToHtml('Opção:') ?></label>
		<select id="cddopcao" name="cddopcao">
			<option value="A" <? echo $cddopcao == 'A' ? 'selected' : '' ?> > A - Alterar</option> 
			<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > C - Consulta</option>
		</select>
	
		<a href="#" class="botao" id="btnOK" onCLick="consultaDados();">OK</a>	
		
		<br style="clear:both" />
	</div>		
</form>


