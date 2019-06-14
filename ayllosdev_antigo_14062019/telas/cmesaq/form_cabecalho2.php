<? 
 /*!
 * FONTE        : form_cabecalho2.php
 * CRIAÇÃO      : Tiago Machado Flôr
 * DATA CRIAÇÃO : 23/12/2011 
 * OBJETIVO     : Formulário de exibição dos campos dependendo do tipo de documento
 * --------------
 * ALTERAÇÕES   : 22/02/2012 - Inclusão do campo para informar 
 *							   conta (quando tipo 0). (Lucas)
 *
 *                15/04/2013 - Padronização de novo layout (David Kruger).
 *                05/09/2013 - Alteração da sigla PAC para PA (Carlos)
 * --------------
 */	
?>
<form name="frmCab2" id="frmCab2" class="formulario" onsubmit="return false;">	
	<fieldset>			
		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="<? echo $cdagenci == 0 ? '' : $cdagenci ?>" />
	
		<div id="dvtipdoc1">	    	    			
			<label for="cdbccxlt">Bco/Cxa:</label>
			<input type="text" id="cdbccxlt" name="cdbccxlt" value="<? echo $cdbccxlt == 0 ? '' : $cdbccxlt ?>" />

			<label for="nrdolote">Lote:</label>
			<input type="text" id="nrdolote" name="nrdolote" value="<? echo $nrdolote == 0 ? '' : $nrdolote ?>" />
				
		</div>

		<div id="dvtipdoc2">
			<label for="nrdcaixa">Caixa:</label>
			<input type="text" id="nrdcaixa" name="nrdcaixa" value="<? echo $nrdcaixa == 0 ? '' : $nrdcaixa ?>" />

			<label for="cdopecxa">Operador:</label>
			<input type="text" id="cdopecxa" name="cdopecxa" value="<? echo $cdopecxa == 0 ? '' : $cdopecxa ?>" />
		</div>
		
		<label for="nrdocmto">Docmto:</label>
		<input type="text" id="nrdocmto" name="nrdocmto" value="<? echo $nrdocmto == 0 ? '' : $nrdocmto ?>" />		
		
		
		<div id="dvtipdoc0">
			<label for="nrdconta"><? echo utf8ToHtml('Conta/Dv:') ?></label>
			<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" />
		</div>
	
	</fieldset>		
</form>