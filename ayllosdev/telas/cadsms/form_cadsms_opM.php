<?php
/*!
 * FONTE        : form_cadsms_OpM.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/10/2016
 * OBJETIVO     : Mostrar campos das opcões 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

?>

<style>
.ui-datepicker-trigger{
    float:left;
    margin-left:2px;
    margin-top:5px;
}
</style>

<div id="divOpcaoM">
<form id="frmOpcaoM" name="frmOpcaoM" class="formulario" style="display:block;">


	<br style="clear:both" />

    <input id="fllindig" name="fllindig" type="checkbox" >
    <label for="fllindig"><? echo utf8ToHtml(' Enviar linha digit&aacute;vel') ?></label>

    <br style="clear:both" />
	<br style="clear:both" />

    <div id="divMensagens" id="divMensagens"></div>

	<hr style="background-color:#666; height:1px;" />

	<div id="divBotoes" style="margin-bottom: 10px;">
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>
		<a href="#" class="botao" id="btnOk"   onClick="confirmaOpcaoM(); return false;">Prosseguir</a>
	</div>

</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmOpcaoM'));
</script>
