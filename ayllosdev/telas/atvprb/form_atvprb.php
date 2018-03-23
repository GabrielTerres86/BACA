<?
/*!
 * FONTE        : form_atvprb.php
 * CRIAÇÃO      : Marcel Kohls / AMCom
 * DATA CRIAÇÃO : 20/03/2018
 * OBJETIVO     : Formulario de dados do cadastro do ativo problemático
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
//echo 
 ?>

<form id="frmAtvPrb" name="frmAtvPrb" class="formulario" style="display:none;">
	<fieldset id="fsDados" style="display:none;">
		<legend> <? echo utf8ToHtml('Dados do Ativo Problem&aacute;tico');  ?> </legend>	
		<label for="tpmotivo">Motivo:</label>
		<select id="tpmotivo" name="tpmotivo" class="mtvSistema">
			<option value="8">8  - S&oacute;cio falecido</option>
			<option value="9">9  - Cooperado preso</option>
			<option value="10">10 - PJ Fal&ecirc;ncia</option>
			<option value="11">11 - PJ Recupera&ccedil;&atilde;o judicial</option>
			<option value="12">12 - Outros - processual</option>
		</select>

		<label for="observac">Observa&ccedil;&atilde;o:</label>
		<input type="text" id="observac" name="observac" value="<?php echo $observac ?>" />

		<div id="datasRegistro">
			<label for="dtinclus">Data Inclus&atilde;o:</label>
			<input type="text" id="dtinclus" name="dtinclus" value="<?php echo $dtinclus ?>" />

			<label for="dtexclus">Data Exclus&atilde;o:</label>
			<input type="text" id="dtexclus" name="dtexclus" value="<?php echo $dtexclus ?>" />
		</div>
	</fieldset>	
	<fieldset id="fsHistorico" style="display:none;">
		<legend> <? echo utf8ToHtml('Hist&oacute;rico de Ativos Problem&aacute;ticos');  ?> </legend>
		<div id="conteudoHistorico">
		</div>
	</fieldset>	
</form>	