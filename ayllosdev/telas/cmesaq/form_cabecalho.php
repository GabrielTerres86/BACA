<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel
 * DATA CRIAÇÃO : 16/11/2011
 * OBJETIVO     : Cabeçalho para a tela CMESAQ
 * --------------
 * ALTERAÇÕES   : 29/06/2016 - Ajuste no campo de opção que não tinha uma descrição
							  para as opções. SD 467402 (Kelvin)
 * --------------
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onsubmit="return false;">
	<div id="divFrmCab"	name="divFrmCab">
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<?php for ($i = 0; $i < count($opcoesTela); $i++) { ?>
		<option value="<?php echo $opcoesTela[$i]; ?>1"<?php if ($opcoesTela[$i] == 'I') { echo " selected"; } ?>><?php if($opcoesTela[$i] == 'I') { echo "I - Incluir"; } elseif($opcoesTela[$i] == 'C'){ echo "C - Consultar"; } elseif($opcoesTela[$i] == 'A'){ echo "A - Alterar"; }  ?></option>
		<?php } ?>	
	</select>
			
	<label for="dtdepesq">Data:</label>
	<input type="text" id="dtdepesq" name="dtdepesq" value="<? echo $dtdepesq == '' ? '' : $dtdepesq ?>" />

	<label for="tpdocmto">Tp. Docmto:</label>	
	<select id="tpdocmto" name="tpdocmto">
		<option value="5">selecione uma op&ccedil&atildeo</option>
		<option value="0">Outros</option>		
		<option value="1">DOC C</option>		
		<option value="2">DOC D</option>		
		<option value="3">TED</option>		
		<option value="4">Dep. Intercooperativa</option>		
	</select>

	
	<br style="clear:both" />	
	</div>
</form>