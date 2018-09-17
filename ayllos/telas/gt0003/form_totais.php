<?php
/*!
 * FONTE        : form_totais.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 24/09/2013
 * OBJETIVO     : Formulario de totais dos valores da tabela da Tela GT0003
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>
<form id="frmTotais" name="frmTotais" class="formulario">
	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
		<legend>Totais</legend>
		<div id="divTotais" >

			<label for="totqtdoc"><? echo utf8ToHtml('Qtd.:') ?></label>
			<input id="totqtdoc" name="totqtdoc" type="text"/>

			<label for="totvldoc"><? echo utf8ToHtml('Arrec.:') ?></label>
			<input id="totvldoc" name="totvldoc" type="text"/>

			<label for="tottarif"><? echo utf8ToHtml('Tarifa:') ?></label>
			<input id="tottarif" name="tottarif" type="text"/>

			<label for="totpagar"><? echo utf8ToHtml('Pagar:') ?></label>
			<input id="totpagar" name="totpagar" type="text"/>

			<br style="clear:both" />
		
		</div>
	</fieldset>
</form>

<div id="divBotoes" style='text-align:center; margin-bottom: 10px; margin-top: 10px;'>
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(2); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>
</div>