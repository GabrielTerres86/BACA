<? 
/*!
 * FONTE        : form_prejuizo.php
 * CRIAÇÃO      : André Socoloski (DB1)
 * DATA CRIAÇÃO : Março/2011 
 * OBJETIVO     : Forumlário de dados de Prestações
 *
 * ALTERACOES:
 *
 *		  001: [03/11/2014] Daniel (CECRED): Incluso novos campos no form frmPreju
 *        002: [04/01/2016] Heitor (RKAM): Inclusao de novo campo para indicar o Tipo de Risco
 */	
?>	

<form name="frmPreju" id="frmPreju" class="formulario" >
	
	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset>
		<legend><? echo utf8ToHtml('Prejuízos do Contrato') ?></legend>
		
		<label for="dtprejuz">Transferido em:</label>
		<input name="dtprejuz" id="dtprejuz" type="text" value="" />
		
		<label for="vlrabono">Valor do Abono:</label>
		<input name="vlrabono" id="vlrabono" type="text" value="" />
		<br />
		
		<label for="vlprejuz"><? echo utf8ToHtml('Prejuízo Original:') ?></label>
		<input name="vlprejuz" id="vlprejuz" type="text" value="" />
				
		<label for="vljrmprj"><? echo utf8ToHtml('Juros do Mês:') ?></label>
		<input name="vljrmprj" id="vljrmprj" type="text" value="" />
		<br />
		
		<label for="slprjori">Sld.Prej.Original:</label>
		<input name="slprjori" id="slprjori" type="text" value="" />
		
		<label for="vljraprj">Juros Acumulados</label>
		<input name="vljraprj" id="vljraprj" type="text" value="" />
		<br />
		
		<label for="vlrpagos">Valores Pagos:</label>
		<input name="vlrpagos" id="vlrpagos" type="text" value="" />
		
		<label for="vlacresc"><? echo utf8ToHtml('Acréscimos:') ?></label>
		<input name="vlacresc" id="vlacresc" type="text" value="" />
		<br />
		
		<label for="vlttmupr">Multa:</label>
		<input name="vlttmupr" id="vlttmupr" type="text" value="" />
		
		<label for="vlttjmpr">Juros de Mora:</label>
		<input name="vlttjmpr" id="vlttjmpr" type="text" value="" />
		<br />
		
		<label for="vlpgmupr">Vlr. Pg. Multa:</label>
		<input name="vlpgmupr" id="vlpgmupr" type="text" value="" />
		
		<label for="vlpgjmpr">Vlr.Pg.Juros Mora:</label>
		<input name="vlpgjmpr" id="vlpgjmpr" type="text" value="" />
		<br />
		
		<label for="vliofcpl">Valor do IOF:</label>
		<input name="vliofcpl" id="vliofcpl" type="text" value="" />
		
		<label for="vlsdprej">Saldo Atualizado:</label>
		<input name="vlsdprej" id="vlsdprej" type="text" value="" />
		<br />
				
		<label for="tpdrisco"><? echo utf8ToHtml('Classif. de Risco:') ?></label>
		<input name="tpdrisco" id="tpdrisco" type="text" value=""/>
	</fieldset>
	
</form>	
		
<div id="divBotoes">
	<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('TC_V')" />
</div>			
