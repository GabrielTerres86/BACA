<?php
/*!
 * FONTE        : form_cadsms_OpP.php
 * CRIA��O      : Odirlei Busana - AMcom
 * DATA CRIA��O : 04/10/2016
 * OBJETIVO     : Mostrar campos das opc�es P
 * --------------
 * ALTERA��ES   : 
 * --------------
 */

?>


<div id="divOpcaoP">
<form id="frmOpcaoP" name="frmOpcaoP" class="formulario" style="display:block;">

    
	<br style="clear:both" />	
    
    <label for="nrdialau"><? echo utf8ToHtml('Quantidade de dias pendentes na LAUTOM:') ?></label>
    <!--<select id="nrdialau" name="nrdialau">    
    </select> -->
    <input type='Text' id="nrdialau" name="nrdialau">
    <br style="clear:both" />	
	<br style="clear:both" />	
    
    <div id="divMensagensP" id="divMensagensP"></div>
    
	<hr style="background-color:#666; height:1px;" />
	
	<div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>	
		<a href="#" class="botao" id="btnOk"   onClick="confirmaOpcaoP(); return false;">Prosseguir</a>	
	</div>
	
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmOpcaoP'));  
</script>
