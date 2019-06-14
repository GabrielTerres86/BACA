<?
/*!
 * FONTE        : form_cncart.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : Setembro/2011
 * OBJETIVO     : Corpo da tela CNCART
 * --------------
 * ALTERAÇÕES   : 17/12/2012 - Ajuste para layout padrao (Daniel).
 *                14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */ 
?>

<fieldset id='tabConteudo' style="display:none">
	<legend>Cart&otilde;es</legend>																					
	<div class="divRegistros"></div>
	<div id="divCampos">
		<label id="lnmtitcrd" for="nmtitcrd">Nome no cart&atilde;o:</label><input type="text" id="nmtitcrd" name="nmtitcrd"/>
		<label id="lcdagenci" for="cdagenci">PA:</label><input type="text" id="cdagenci" name="cdagenci"/>
	</div>
</fieldset>

<div id="divBotoes" style="display:none">	
	<a href="#" class="botao" id="btVoltar" onClick="Voltar();return;">Voltar</a>
</div>

