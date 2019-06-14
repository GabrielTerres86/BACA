<?
/*!
 * FONTE        : form_confirma_sisbacen.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 08/05/2012
 * OBJETIVO     : Mostrar campos da opcao F - Efetuar confirmacao de digitacao dos dados no Sisbacen
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divConfirmaSisbacen">
<form id="frmConfirmaSisbacen" name="frmConfirmaSisbacen" class="formulario">

	
	<label for="nmrescop"><? echo utf8ToHtml('Cooperativa:') ?></label>
	<select id="nmrescop" name="nmrescop">
	</select>
	
	<br/>
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
	
	
	
	<div id="divDadosConfirmaSisbacen">
	</div>
	
	<div id="divBotoes" style="margin-top:5px; margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar"   onclick="estadoInicial(); return false;" >Voltar</a>
		<a href="#" class="botao" id="btnOK"   onclick="consultaDadosFechamento(); return false;" >Prosseguir</a>
	</div>
	
</form>
</div>
