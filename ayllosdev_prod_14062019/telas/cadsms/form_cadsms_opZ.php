<?php
/*!
 * FONTE        : form_cadsms_OpZ.php
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

<div id="divOpcaoZ">
<form id="frmOpcaoZ" name="frmOpcaoZ" class="formulario" style="display:block;">
   
	<br style="clear:both" />	
    
    <div id="divLotes" id="divLotes">
      <div class="divRegistros"></div>
    </div>
    
	<hr style="background-color:#666; height:1px;" />
	
	<div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>	
		<a href="#" class="botao" id="btnOk"   onClick="confirmaOpcaoZ(); return false;">Prosseguir</a>	
	</div>
	
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmOpcaoM'));  
</script>
