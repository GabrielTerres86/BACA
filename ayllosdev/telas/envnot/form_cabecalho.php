<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Jean Michel         
	 * DATA CRIAÇÃO : 11/09/2017
	 * OBJETIVO     : Cabecalho para a tela ENVNOT
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
	<table width="100%">
		<tr>	
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:&nbsp;') ?></label>
				<select id="cddopcao" name="cddopcao" onChange="$('#divConteudo').empty();" class="Campo" style="width:85%">
					<?php if ($glbvars["cdcooper"] == 3) { ?>
						<option value="A" >A - Alterar notifica&ccedil;&otilde;es autom&aacute;ticas</option>
					<?php } ?>
					<option value="C" >C - Consultar notifica&ccedil;&otilde;es enviadas</option>
					<option value="N" >N - Enviar notifica&ccedil;&atilde;o manual</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick = "escolheOpcao($('#cddopcao').val());" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>
<div id="divListErr" style="display:none;"></div>
<div id="divListMsg" style="display:block;"></div>
<div id="divViewMsg" style="display:none;"></div>