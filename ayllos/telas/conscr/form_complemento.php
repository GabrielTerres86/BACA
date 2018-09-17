<? 
 /*!
 * FONTE        : form_complemento.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 07/12/2011 
 * OBJETIVO     : Formulário de exibição das informações da central de risco da tela CONSCR.
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */	
?>
<form name="frmComplemento" id="frmComplemento" class="formulario" onSubmit="return false;" >	

	<fieldset>
	
		<legend> <? echo utf8ToHtml('Consulta') ?> </legend>	

		<label for="dtrefere">Data Base Bacen:</label>
		<input id="dtrefere" name="vlvencto" type="text" value="<?php echo getByTagName($registro[0]->tags,'dtrefere');  ?>" />

		<label for="qtopesfn">Qt.Oper.:</label>
		<input id="qtopesfn" name="qtopesfn" type="text" value="<?php echo getByTagName($registro[0]->tags,'qtopesfn');  ?>" />

		<label for="qtifssfn">Qt. IFs:</label>
		<input id="qtifssfn" name="qtifssfn" type="text" value="<?php echo getByTagName($registro[0]->tags,'qtifssfn');  ?>" />

		<label for="vlopesfn">Op.SFN:</label>
		<input id="vlopesfn" name="vlopesfn" type="text" value="<?php echo getByTagName($registro[0]->tags,'vlopesfn');  ?>" />

		<label for="vlopevnc">Op.Venc.:</label>
		<input id="vlopevnc" name="vlopevnc" type="text" value="<?php echo getByTagName($registro[0]->tags,'vlopevnc');  ?>" />

		<label for="vlopeprj">Op. Prej:</label>
		<input id="vlopeprj" name="vlopeprj" type="text" value="<?php echo getByTagName($registro[0]->tags,'vlopeprj');  ?>" />
		
		<br style="clear:both" />
		<br />
		
		<label for="vlopcoop">OP.COOP.ATUAL:</label>
		<input id="vlopcoop" name="vlopcoop" type="text" value="<?php echo getByTagName($registro[0]->tags,'vlopcoop');  ?>" />
		<input id="dtrefaux" name="dtrefaux" type="text" value="<?php echo getByTagName($registro[0]->tags,'dtrefaux');  ?>" />
		

		<label for="vlopbase">OP.COOP.BACEN:</label>
		<input id="vlopbase" name="vlopbase" type="text" value="<?php echo getByTagName($registro[0]->tags,'vlopbase');  ?>" />
		<input id="dtrefer2" name="dtrefer2" type="text" value="<?php echo getByTagName($registro[0]->tags,'dtrefer2');  ?>" />
		
	</fieldset>		

</form>


 <!-- <div id="divMsgAjuda"> -->
<!--	<span><? /* echo utf8ToHtml('Clique no botão VOLTAR para sair!.') */?></span> -->

	<div id="divBotoes" style="margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;" >Voltar</a>
	</div>

<!-- </div>			-->														
