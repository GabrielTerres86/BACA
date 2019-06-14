<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/09/2013
 * OBJETIVO     : Formulario de Listagem dos dados da Tela GT0003
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
<form id="frmConsulta" name="frmConsulta" class="formulario">

	<fieldset>
		<legend>Filtros</legend>

		<div id="divConsulta" style="width:618px">
		
		<label for="dtmvtolt"><? echo utf8ToHtml('Data:') ?></label>
		<input id="dtmvtolt" name="dtmvtolt" type="text"/>
		
		<br style="clear:both" />
		
		<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<input id="cdcooper" name="cdcooper" type="text" maxlength="2" />
	
		<label for="nmrescop"><? echo utf8ToHtml('Nome:') ?></label>
		<input id="nmrescop" name="nmrescop" type="text"/>
		
		<label for="cdconven"><? echo utf8ToHtml('Cod. Convênio:') ?></label>
		<input id="cdconven" name="cdconven" type="text" maxlength="4" />
		
		<label for="nmempres"><? echo utf8tohtml('Empresa:') ?></label>
		<input id="nmempres" name="nmempres" type="text"/>
		
		<label for="cdcopdom"><? echo utf8ToHtml('Cooperativa Domínio:') ?></label>
		<input id="cdcopdom" name="cdcopdom" type="text"/>
					
		<label for="nrcnvfbr"><? echo utf8ToHtml('Febraban:') ?></label>
		<input id="nrcnvfbr" name="nrcnvfbr" type="text"/>
						
		<label for="dtcredit"><? echo utf8ToHtml('Crédito:') ?></label>
		<input id="dtcredit" name="dtcredit" type="text"/>
		
		<label for="nmarquiv"><? echo utf8ToHtml('Arquivo:') ?></label>
		<input id="nmarquiv" name="nmarquiv" type="text"/>
		
		<label for="qtdoctos"><? echo utf8ToHtml('Quantidade Doctos:') ?></label>
		<input id="qtdoctos" name="qtdoctos" type="text"/>
		
		<label for="vldoctos"><? echo utf8ToHtml('Total Arrecadado:') ?></label>
		<input id="vldoctos" name="vldoctos" type="text"/>
		
		<label for="vltarifa"><? echo utf8ToHtml('Total de Tarifas:') ?></label>
		<input id="vltarifa" name="vltarifa" type="text"/>
		
		<label for="vlapagar"><? echo utf8ToHtml('Total a Pagar:') ?></label>
		<input id="vlapagar" name="vlapagar" type="text"/>
		
		<label for="nrsequen"><? echo utf8ToHtml('Nro Seq.:') ?></label>
		<input id="nrsequen" name="nrsequen" type="text"/>				

		<br style="clear:both" />
		
		</div>
	</fieldset>
</form>

