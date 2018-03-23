<?
/*!
 * FONTE        : form_contacontrato.php
 * CRIAÇÃO      : Marcel Kohls / AMCom
 * DATA CRIAÇÃO : 20/03/2018
 * OBJETIVO     : Formulario de conta e contrato
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 ?>

<form id="frmFiltro" name="frmFiltro" class="formulario">

	<fieldset>
		<legend> <? echo utf8ToHtml('Filtros');  ?> </legend>	
		<label for="flmotivo">Motivo:</label>
		<select id="flmotivo" name="flmotivo">
			<option value='0'>0  - Todos</option>
			<option value='1'>1  - 90 dias atraso</option>
			<option value='2'>2  - 90 dias atraso (Reestruturação)</option>
			<option value='3'>3  - Opera&ccedil;&otilde;es a partir do risco D sem atraso</option>
			<option value='4'>4  - Prejuízo</option>
			<option value='5'>5  - Penhora</option>
			<option value='6'>6  - Bloqueio terceiros</option>
			<option value='7'>7  - Outros juridico</option>
			<option value="8">8  - S&oacute;cio falecido</option>
			<option value="9">9  - Cooperado preso</option>
			<option value="10">10 - PJ Fal&ecirc;ncia</option>
			<option value="11">11 - PJ Recupera&ccedil;&atilde;o judicial</option>
			<option value="12">12 - Outros - processual</option>
		</select>

		<label for="fldtinic">Data Inicial:</label>
		<input type="text" id="fldtinic" name="fldtinic" value="<?php echo $dtinclus ?>" />

		<label for="fldtfina">Data Final:</label>
		<input type="text" id="fldtfina" name="fldtfina" value="<?php echo $dtexclus ?>" />
	</fieldset>	

</form>