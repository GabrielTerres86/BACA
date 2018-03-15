<?php
	/*!
	 * FONTE        : form_cabecalho.php
	 * CRIAÇÃO      : Gustavo Meyer         
	 * DATA CRIAÇÃO : 26/02/2017
	 * OBJETIVO     : Cabecalho para a tela PARBAN
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
	<table width="100%">
		<tr>	
			<td>
				<label for="cdcanal"><? echo utf8ToHtml('Canal:&nbsp;&nbsp;') ?></label>
				<select id="cdcanal" name="cdcanal" class="Campo" style="width:85%">
					<option value="10" >Mobile Banking</option>
					<!-- <option value="31" >Internet Banking</option> -->
				</select>

			</td>
		</tr>
		<tr>
			<td>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:&nbsp;') ?></label>
				<select id="cddopcao" name="cddopcao" onChange="$('#divConteudo').empty();" class="Campo" style="width:85%">
					<option value="I" >I - Inserir Banner</option>
					<option value="C" >C - Consultar Banners</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick = "escolheOpcao($('#cddopcao').val(),$('#cdcanal').val());" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>
<div id="divListErr" style="display:none;"></div>
<div id="divListMsg" style="display:block;"></div>
<div id="divViewMsg" style="display:none;"></div>