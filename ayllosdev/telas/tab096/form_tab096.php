<?
/*!
 * FONTE        	: form_tab096.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Julho/2015
 * OBJETIVO     	: Cabeçalho para a tela TAB096
 * ÚLTIMA ALTERAÇÃO : 07/03/2017
 * --------------
 * ALTERAÇÕES   	: 07/03/2017 - Adicao do campo descprej. (P210.2 - Jaison/Daniel)
 * --------------
 * 20/06/2018 - Adicionado tipo de produto desconto de título - Luis Fernando (GFT)
 */ 
?>

<form id="frmTab096" name="frmTab096" class="formulario" style="display:none; border-bottom: 1px solid #777777; ">		

	<label for="nrconven"><? echo utf8ToHtml('Conv&ecirc;nio de Cobran&ccedil;a:') ?></label>
	<select id="nrconven" name="nrconven"></select>	
	<br style="clear:both" />	

	<label for="nrdconta"><? echo utf8ToHtml('Conta/DV Benefici&aacute;ria:') ?></label>
	<input name="nrdconta" id="nrdconta" type="text" />	
	<br style="clear:both" />	

	<label for="prazomax"><? echo utf8ToHtml('Prazo m&aacute;ximo de vencimento:') ?></label>
	<input name="prazomax" id="prazomax" type="text" style="margin-right: 5px"/>		
	<label><? echo utf8ToHtml(' dias') ?></label>
	<br style="clear:both" />

	<label for="prazobxa"><? echo utf8ToHtml('Prazo de baixa para o boleto ap&oacute;s vencimento:') ?></label>
	<input name="prazobxa" id="prazobxa" type="text" style="margin-right: 5px" />							
	<label><? echo utf8ToHtml(' dias') ?></label>
	<br style="clear:both" />

	<label for="vlrminpp"><? echo $tpproduto == 3 ? utf8ToHtml('Valor m&iacute;nimo do boleto:') : utf8ToHtml('Valor m&iacute;nimo do boleto - PP:') ?></label>
	<input name="vlrminpp" id="vlrminpp" type="text" />		
	<br style="clear:both" />	

	<?php if ($tpproduto == 0 ) {?>
	<label for="vlrmintr"><? echo utf8ToHtml('Valor m&iacute;nimo do boleto - TR:') ?></label>
	<input name="vlrmintr" id="vlrmintr" type="text" />				
	<br style="clear:both" />	
	<?php } ?>

	<?php if ($tpproduto ==  0) {?>
	<label for="vlrminpos"><? echo utf8ToHtml('Valor m&iacute;nimo do boleto - POS:') ?></label>
	<input name="vlrminpos" id="vlrminpos" type="text" />
	<br style="clear:both" />
	<?php } ?>

	<label for="descprej"><? echo utf8ToHtml('Desconto M&aacute;ximo Contrato Preju&iacute;zo:') ?></label>
	<input name="descprej" id="descprej" type="text" style="margin-right: 5px"/>				
	<label><? echo utf8ToHtml(' %') ?></label>

	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('Instru&ccedil;&otilde;es ( Mensagens do Boleto)'); ?> </legend>

		<label for="dslinha1"><? echo utf8ToHtml('Linha 1:') ?></label>
		<input name="dslinha1" id="dslinha1" type="text" />			
		<br style="clear:both" />

		<label for="dslinha2"><? echo utf8ToHtml('Linha 2:') ?></label>
		<input name="dslinha2" id="dslinha2" type="text" />			
		<br style="clear:both" />

		<label for="dslinha3"><? echo utf8ToHtml('Linha 3:') ?></label>
		<input name="dslinha3" id="dslinha3" type="text" />								
		<br style="clear:both" />

		<label for="dslinha4"><? echo utf8ToHtml('Linha 4:') ?></label>
		<input name="dslinha4" id="dslinha4" type="text" />				

	</fieldset>
	
	<br style="clear:both" />
	
	<fieldset style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('Texto SMS'); ?> </legend>

		<textarea name="dstxtsms" id="dstxtsms" rows="4" cols="56" maxlength="140" style="margin-left: 15px; margin-top: 10px; margin-bottom: 10px;" ></textarea>
	
		<p style=" margin-left: 15px; font-family:Arial, Helvetica, sans-serif; font-size:11px;"><? echo utf8ToHtml('Obs.: Os campos "#LinhaDigitavel#", "#Cooperativa#", "#Cooperado#", #Contrato#, #Valor# e #Vencimento# s&atilde;o preenchidos automaticamente pelo sistema.') ?></p>
	</fieldset>
	<br style="clear:both" />
	
	<fieldset style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('Texto E-mail'); ?> </legend>
	<textarea name="dstxtema" id="dstxtema" rows="4" cols="56" maxlength="1000" style="margin-left: 15px; margin-top: 10px; margin-bottom: 10px;" ></textarea>
	</fieldset>
	<br style="clear:both" />

	<label for="blqemiss" ><? echo utf8ToHtml('Bloqueio de emiss&atilde;o de boletos:') ?></label>
	<input name="blqemiss" id="blqemiss" type="text" style="margin-right: 5px"/>			
	<label><? echo utf8ToHtml('dias para ') ?></label>
	<input name="emissnpg" id="emissnpg" type="text" style="margin-right: 5px" />
	<label><? echo utf8ToHtml('emiss&otilde;es lidas n&atilde;o pagas') ?></label>

	<br style="clear:both" />
	<label for="qtdmaxbl"><? echo utf8ToHtml('Quantidade m&aacute;xima de boletos por contrato:') ?></label>
	<input name="qtdmaxbl" id="qtdmaxbl" type="text" />				
	<br style="clear:both" />

	<label for="flgblqvl"><? echo utf8ToHtml('Bloqueio de resgate de valores dispon&iacute;veis em C/C:') ?></label>
	<select id="flgblqvl" name="flgblqvl">						
	<option value="S" selected>SIM</option>
	<option value="N" selected>NAO</option>
	</select>

	<br style="clear:both" />	
	
</form>
