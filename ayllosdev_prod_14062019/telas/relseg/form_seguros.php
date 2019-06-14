<? 
/*!
 * FONTE        : form_seguros.php
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 22/02/2013
 * OBJETIVO     : Formulario de Seguros da tela RELSEG.
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<form id="frmSeg" name="frmSeg" class="formulario">
    <fieldset id="frmConteudo" style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">
	<legend><? echo utf8ToHtml('Par&#226;metros de comiss&#227;o dos seguros.') ?></legend>
		<div id="divSeg">
		    </br>
		    <fieldset>
				<legend><? echo utf8ToHtml('Seguro Auto:') ?></legend>
				<label for="vlrdecom1">Comissão:</label>
				<input type="text" id="vlrdecom1" name="vlrdecom1" value="<? echo $vlrdecom1 == 0 ? '' : $vlrdecom1 ?>" alt="Informe o valor de comissão." />	
				<label for="vlrdeiof1">IOF:</label>
				<input type="text" id="vlrdeiof1" name="vlrdeiof1" value="<? echo $vlrdeiof1 == 0 ? '' : $vlrdeiof1 ?>" alt="Informe o valor de IOF." />	
				<label for="vlrapoli">Apólice:</label>
				<input type="text" id="vlrapoli" name="vlrapoli" value="<? echo $vlrapoli == 0 ? '' : $vlrapoli ?>" alt="Informe o valor da apólice." />	
				<input type="hidden" id="recid1" name="recid1"   value="<? echo $recid1 == 0 ? '' : $recid1 ?>" />
			</fieldset>
			</br>
			<fieldset>
				<legend><? echo utf8ToHtml('Seguro Vida:') ?></legend>
				<label for="vlrdecom2">Comissão:</label>
				<input type="text" id="vlrdecom2" name="vlrdecom2" value="<? echo $vlrdecom2 == 0 ? '' : $vlrdecom2 ?>" alt="Informe o valor de comissão." />	
				<label for="vlrdeiof2">IOF:</label>
				<input type="text" id="vlrdeiof2" name="vlrdeiof2" value="<? echo $vlrdeiof2 == 0 ? '' : $vlrdeiof2 ?>" alt="Informe o valor de IOF." />	
				<input type="hidden" id="recid2" name="recid2"     value="<? echo $recid2 == 0 ? '' : $recid2 ?>" />
			</fieldset>
			</br>
			<fieldset>
				<legend><? echo utf8ToHtml('Seguro Resid&#234;ncial:') ?></legend>
				<label for="vlrdecom3">Comissão:</label>
				<input type="text" id="vlrdecom3" name="vlrdecom3" value="<? echo $vlrdecom3 == 0 ? '' : $vlrdecom3 ?>" alt="Informe o valor de comissão." />	
				<label for="vlrdeiof3">IOF:</label>
				<input type="text" id="vlrdeiof3" name="vlrdeiof3" value="<? echo $vlrdeiof3 == 0 ? '' : $vlrdeiof3 ?>" alt="Informe o valor de IOF." />
				<input type="hidden" id="recid3" name="recid3"     value="<? echo $recid3 == 0 ? '' : $recid3 ?>" />
			</fieldset>
			</br>
		</div>
	</fieldset>
	
	<br style="clear:both" />
	</br>
</form>
