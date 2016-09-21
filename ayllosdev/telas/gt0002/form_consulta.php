<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod(); 
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 19/09/2013
 * OBJETIVO     : Formulario de Listagem dos convenios por cooperativas da Tela GT0002
 * --------------
 * ALTERAÇÕES   :
 * --------------
 
 16/05/2016 - #412560 Acentuações; Inclusão da class inteiro em "Cooperativa" e "Cód. Convênio", 
              para permitir apenas números inteiros (Carlos)
 
 */ 
?>

<form id="frmConsulta" name="frmConsulta" class="formulario">
	<fieldset>
		<legend><? echo utf8ToHtml('Filtros') ?></legend>
		<div id="divConsulta" >
		
			<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
			<input id="cdcooper" name="cdcooper" type="text" class="inteiro" maxlength="2" />
		
			<label for="nmrescop"><? echo utf8ToHtml('Nome:') ?></label>
			<input id="nmrescop" name="nmrescop" type="text"/>
			
			<br style="clear:both" />
			
			<label for="cdconven"><? echo utf8ToHtml('Cód. Convênio:') ?></label>
			<input id="cdconven" name="cdconven" type="text" class="inteiro" maxlength="4" />
					
			<label for="nmempres"><? echo utf8ToHtml('Nome Convênio:') ?></label>
			<input id="nmempres" name="nmempres" type="text"/>
						
			
		
		</div>
	</fieldset>
</form>

<div id="divBotoesConsulta" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;'>
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(1); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>
</div>