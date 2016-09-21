<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 15/03/2016
 * OBJETIVO     : Cabecalho para a tela MANPAC
 * --------------
 * ALTERAÇÕES   : 
 *
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" > 
	<div id="divCab">
		<input id="registro" name="registro" type="hidden" value=""  />
		<input id="pctcontas" name="pctcontas" type="hidden" value=""  />
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
		
		<label for="cddopcao"><?php echo utf8ToHtml('Opção:') ?></label>
		<select id="cddopcao" name="cddopcao">
			<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > C - Consultar</option>
			<option value="D" <? echo $cddopcao == 'D' ? 'selected' : '' ?> > D - Desativar</option>
			<option value="H" <? echo $cddopcao == 'H' ? 'selected' : '' ?> > H - Habilitar</option>
		</select>	
		<a href="#" class="botao" id="btnOK" onClick="verificaAcao('C');">OK</a>			
		<br style="clear:both" />
	</div>		
</form>
