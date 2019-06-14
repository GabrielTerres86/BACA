<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)						Última Alteração: 03/12/2014
 * DATA CRIAÇÃO : 24/02/2014
 * OBJETIVO     : Formulario de Consulta de Movimentação da Tela MOVTOS
 * --------------
 * ALTERAÇÕES   : 03/12/2014 - Ajustes para liberação (Adriano).
 * --------------
 */ 
?>

<?

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmConsulta" name="frmConsulta" class="formulario" style="display:none;">
	
	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0x; padding-bottom:10px;">
	
		<div id="divConsulta" >
		
			<label for="tpdopcao"><? echo utf8ToHtml('Tipo:') ?></label>
			<select id="tpdopcao" name="tpdopcao">
				<option value="Todos Cartoes" selected><? echo utf8ToHtml('Todos os Cartões')?> </option>
				<option value="Por Periodo" ><? echo utf8ToHtml('Por Período') ?> </option>
				<option value="Gerar base" ><? echo utf8ToHtml('Gerar Base') ?> </option>
			</select>
			
			<label for="dtinicio"><? echo utf8ToHtml('Inicial:') ?></label>
			<input id="dtinicio" name="dtinicio" type="text"/>
		
			<label for="ddtfinal"><? echo utf8ToHtml('Final:') ?></label>
			<input id="ddtfinal" name="ddtfinal" type="text"/>
												
			<label for="dsadmcrd"><? echo utf8ToHtml('Cartão:') ?></label>
			<select id="dsadmcrd" name="dsadmcrd">
				<option value="BANCO DO BRASIL" selected><? echo utf8ToHtml('Banco do Brasil')?> </option>
				<option value="BRADESCO" ><? echo utf8ToHtml('Bradesco') ?> </option>
			</select>
			
			<label for="tpdomvto"><? echo utf8ToHtml('Movimento:') ?></label>
			<select id="tpdomvto" name="tpdomvto">
				<option value="C" selected><? echo utf8ToHtml('C')?> </option>
				<option value="D" ><? echo utf8ToHtml('D') ?> </option>
			</select>
			
			<br style="clear:both" />
			
			<label for="dtprdini"><? echo utf8ToHtml('Inicial:') ?></label>
			<input id="dtprdini" name="dtprdini" type="text"/>
			
			<label for="dtprdfin"><? echo utf8ToHtml('Final:') ?></label>
			<input id="dtprdfin" name="dtprdfin" type="text"/>
			
									
			<label for="lgvisual"><? echo utf8ToHtml('Saída:') ?></label>
			<select id="lgvisual" name="lgvisual">
				<option value="A" selected><? echo utf8ToHtml('Arquivo') ?> </option>
				<option value="I"><? echo utf8ToHtml('Impressão') ?> </option>				
			</select>
			
			<br style="clear:both" />
						
			<label name="situacao" id="situacaoCartao"><? echo utf8ToHtml('Situação do Cartão:')?></label>
						
			<label name="situacao" id="labelSituacao1" class="checkbox"><? echo utf8ToHtml('1 - Estudo') ?></label>
			<input name="situacao1" id="situacao1" type="checkbox" class="checkbox" value="1" >
			
			<label name="situacao" id="labelSituacao2" class="checkbox"><? echo utf8ToHtml('2 - Aprov.') ?></label>
			<input name="situacao2" id="situacao2" type="checkbox" class="checkbox" value="2" >
			
			<label name="situacao" id="labelSituacao3" class="checkbox"><? echo utf8ToHtml('3 - Prc.BB') ?></label>
			<input name="situacao3" id="situacao3" type="checkbox" class="checkbox" value="3" >
			
			<label name="situacao" id="labelSituacao4" class="checkbox"><? echo utf8ToHtml('4 - Bloque') ?></label>
			<input name="situacao4" id="situacao4" type="checkbox" class="checkbox" value="4" >
			
			<label name="situacao" id="labelSituacao5" class="checkbox"><? echo utf8ToHtml('5 - Encer.') ?></label>
			<input name="situacao5" id="situacao5" type="checkbox" class="checkbox" value="5" >					
			
		</div>
		
		<div id="divSaida">
		
			<label for="lgvisual"><? echo utf8ToHtml('Saída:') ?></label>
			<select id="lgvisual" name="lgvisual">
				<option value="A" selected><? echo utf8ToHtml('Arquivo') ?> </option>
				<option value="I"><? echo utf8ToHtml('Impressão') ?> </option>
			</select>
		
		</div>
		
		<div id="divSituacao">
		
			<label name="situacao" id="situacaoCartao"><? echo utf8ToHtml('Situação do Cartão:')?></label>
			
			<label name="situacao" id="labelSituacao1" class="checkbox"><? echo utf8ToHtml('1 - Sol.2v') ?></label>
			<input name="situacao" id="situacao1" type="checkbox" class="checkbox" value="1" >
			
			<label name="situacao" id="labelSituacao2"class="checkbox"><? echo utf8ToHtml('2 - Estudo') ?></label>
			<input name="situacao" id="situacao2" type="checkbox" class="checkbox" value="2" >
			
			<label name="situacao" id="labelSituacao3" class="checkbox"><? echo utf8ToHtml('3 - Aprov.') ?></label>
			<input name="situacao" id="situacao3" type="checkbox" class="checkbox" value="3" >
					
			<label name="situacao" id="labelSituacao4" class="checkbox"><? echo utf8ToHtml('4 - Solic.') ?></label>
			<input name="situacao" id="situacao4" type="checkbox" class="checkbox" value="4" >
			
			<label name="situacao" id="labelSituacao5" class="checkbox"><? echo utf8ToHtml('5 - Liber.') ?></label>
			<input name="situacao" id="situacao5" type="checkbox" class="checkbox" value="5" >
			
			<br style="clear:both" />
			
			<label name="situacao" id="labelSituacao6" class="checkbox"><? echo utf8ToHtml('6 - Em uso') ?></label>
			<input name="situacao" id="situacao6" type="checkbox" class="checkbox" value="6" >
			
			<label name="situacao" id="labelSituacao7" class="checkbox"><? echo utf8ToHtml('7 - Cancel') ?></label>
			<input name="situacao" id="situacao7" type="checkbox" class="checkbox" value="7" >
					
		</div>				
		
	</fieldset>
	
	<br style="clear:both" />
	
</form>


