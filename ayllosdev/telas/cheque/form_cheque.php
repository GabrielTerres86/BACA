<?
/*!
 * FONTE        : form_cheque.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 13/05/2011
 * OBJETIVO     : Formulário para Cheques da tela CHEQUE
 * ALTERAÇÕES   : 04/09/2012 - Inclusao de novos campos no form_cheque (Tiago)
 *                18/12/2012 - Retirar o campo Conta da TIC (Ze).
 *				  30/06/2014 - Adicionado campo cdageaco nos detalhes do cheque. (Reinert)
 *				  10/06/2016 - Incluir style nos forms (Lucas Ranghetti #422753)
 *				  29/05/2019 - Inclusão do valor do acerto (Jackson Barcellos - AMcom)
 */  
?>

<form id="frmCheque" name="frmCheque" class="formulario" style="width: 720px;">
	<fieldset>
		<legend>Detalhes do Cheque</legend>
		
		<label for="nrpedido">Pedido:</label>
		<input type="text" name="nrpedido" id="nrpedido" />
		
		<label for="dtsolped">Enviado em:</label>
		<input type="text" name="dtsolped" id="dtsolped" />
		
		<label for="dtrecped">Recebido em:</label>
		<input type="text" name="dtrecped" id="dtrecped" />
		<br />
		
		<label for="dsdocmc7">CMC-7:</label>
		<input type="text" name="dsdocmc7" id="dsdocmc7" />
		<br />
		
		<label for="dscordem">Contra-Ordem:</label>
		<input type="text" name="dscordem" id="dscordem" />
		<br />			

		<label for="dtmvtolt"></label>
		<input type="text" name="dtmvtolt" id="dtmvtolt" />
		<br />			
		
		<label for="dsobserv"><? echo utf8ToHtml('Observação:') ?></label>
		<input type="text" name="dsobserv" id="dsobserv" />
		<br />	
		
		<label for="cdbandep">Depositado no Banco:</label>
		<input name="cdbandep" id="cdbandep" type="text" />

		<label for="cdagedep"><? echo utf8ToHtml('Agência:') ?></label>
		<input name="cdagedep" id="cdagedep" type="text" />

		<label for="nrctadep">Conta:</label>
		<input name="nrctadep" id="nrctadep" type="text" />
		<br />		
		
		<label for="cdageaco">Coop. Acolhedora:</label>
		<input name="cdageaco" id="cdageaco" type="text" />

		<label for="cdtpdchq">TD:</label>
		<input name="cdtpdchq" id="cdtpdchq" type="text" />
		
		<label for="vlcheque">Valor:</label>
		<input name="vlcheque" id="vlcheque" type="text" />		

		<br />

		<label for="cdbantic">Custodiado no Banco:</label>
		<input name="cdbantic" id="cdbantic" type="text" />

		<label for="cdagetic"><? echo utf8ToHtml('Agência:') ?></label>
		<input name="cdagetic" id="cdagetic" type="text" />

		<label for="vlacerto"><? echo utf8ToHtml('Valor do acerto:') ?></label>
		<input  name="vlacerto" id="vlacerto" type="text" />
		<br />

		<label for="dtlibtic"><? echo utf8ToHtml('Liberação em:') ?></label>
		<input  name="dtlibtic" id="dtlibtic" type="text" />
		<br />

		<br style="clear:both" />
	</fieldset>		
</form>