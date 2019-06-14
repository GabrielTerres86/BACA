<?php
	/*!
    * FONTE        : form_cadastro_motivo_cin.php
	* CRIAÇÃO      : Douglas Quisinski
	* DATA CRIAÇÃO : 25/08/2015
	* OBJETIVO     : Cadastro de Motivos CIN
	* --------------
	* ALTERAÇÕES   : 
	* --------------
	*/
?>
<form id="frmMotivoCin" name="frmMotivoCin" class="formulario" onSubmit="return false;" style="display:block">
	<label for="cdmotivocin"><? echo utf8ToHtml("C&oacute;digo:") ?></label>
	<input name="cdmotivocin" type="text"  id="cdmotivocin" class="campo" />
	<a id="pesqmotcin" name="pesqmotcin" href="#" onClick="mostrarPesquisaMotivoCin('#frmMotivoCin,#divBotoes');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
	<br/>

	<label for="dsmotivocin"><? echo utf8ToHtml("Motivo CIN:") ?></label>
	<input name="dsmotivocin" type="text"  id="dsmotivocin" class="campo alphanum" />
	<br style="clear:both" />
</form>