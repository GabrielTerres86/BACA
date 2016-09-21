<? 
/*!
 * FONTE        : form_nova_garantia.php
 * CRIAÇÃO      : Rogério Giacomini (GATI)
 * DATA CRIAÇÃO : 15/09/2011 
 * OBJETIVO     : Formulário para inclusão de uma garantia da tela GARSEG
 * --------------
 * ALTERAÇÕES   : 
 * 001: 18/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 * 
 */
 ?>
<form name="frmGarantia" id="frmGarantia" class="formulario condensado">	
	<fieldset>
		<legend>Garantia de Seguro</legend>
		<label for="dsgarant"><? echo utf8ToHtml("Descrição da Garantia:"); ?></label>
		<input name="dsgarant" id="dsgarant" type="text"/>
		<label for="vlgarant">Valor Garantia:</label>
		<input name="vlgarant" id="vlgarant" type="text"/>
		<label for="dsfranqu"><? echo utf8ToHtml("Descrição da Franquia:"); ?></label>
		<input name="dsfranqu" id="dsfranqu" type="text"/>
	</fieldset>
</form>
<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="escondeRotina(); return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar" >Concluir</a> <!-- controle feito no js -->
</div>