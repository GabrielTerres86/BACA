<? 
 /*!
 * FONTE        : form_principal.php
 * CRIAÇÃO      : Dioathan
 * DATA CRIAÇÃO : 05/05/2016
 * OBJETIVO     : Formulário principal da tela PARMDA
 * --------------
 * ALTERAÇÕES   :  30/08/2017 - Inserir os Divs para permitir ocultar os campos conforme 
 *  							opções parametrizadas. (Renato Darosci - Prj360)
 */	
?>

<form name="frmPrincipal" id="frmPrincipal" class="formulario">	

	<div id="div_flgenvia_sms">
	<label for="flgenvia_sms"><? echo utf8ToHtml('Cooperativa envia SMS:') ?></label>
	<input name="flgenvia_sms" id="flgenvia_sms" type="checkbox" />
	<br style="clear:both" />
	</div>
	
	<div id="div_flgcobra_tarifa">
	<label for="flgcobra_tarifa"><? echo utf8ToHtml('Cobrar Tarifa do Cooperado:') ?></label>
	<input name="flgcobra_tarifa" id="flgcobra_tarifa" type="checkbox" />
	<br style="clear:both" />
	
	<label for="cdtarifa_pf"><? echo utf8ToHtml('Código Tarifa Pessoa Física:') ?></label>
	<input name="cdtarifa_pf" id="cdtarifa_pf" type="text" />
	<label for="vltarifa_pf" style="margin-left: 10px;"><? echo utf8ToHtml('Valor:') ?></label>
	<input name="vltarifa_pf" id="vltarifa_pf" type="text" style="display:block;" />
	<br style="clear:both" />
	
	<label for="cdtarifa_pj"><? echo utf8ToHtml('Código Tarifa Pessoa Jurídica:') ?></label>
	<input name="cdtarifa_pj" id="cdtarifa_pj" type="text" />
	<label for="vltarifa_pj" style="margin-left: 10px;"><? echo utf8ToHtml('Valor:') ?></label>
	<input name="vltarifa_pj" id="vltarifa_pj" type="text" style="display:block;" />
	<br style="clear:both" />
	</div>
	
	<div id="div_hrenvio_sms">
	<label for="hrenvio_sms"><? echo utf8ToHtml('Horário de Envio:') ?></label>
	<input name="hrenvio_sms" id="hrenvio_sms" type="text" />
	<br style="clear:both" />
	</div>
	
	<div id="divMensagens" id="divMensagens"></div>
</form>