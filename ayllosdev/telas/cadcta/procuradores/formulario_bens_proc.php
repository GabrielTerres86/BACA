<? 
/*!
 * FONTE        : formulario_bens.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 16/09/2010 
 * OBJETIVO     : Forumlário de dados de Bens para alteracao
 */	
?>	

<? $bem = $regBens[0]->tags; ?>

<div id="divProcBensFormulario">
	<form name="frmProcBens" id="frmProcBens" class="formulario">
		<label for="dsrelbem">Descri&ccedil;&atilde;o do bem:</label>
		<input name="dsrelbem" id="dsrelbem" type="text" class="alphanum" maxlength="40" value="" />
		<br />
		
		<label for="persemon">Percentual sem &ocirc;nus:</label>
		<input name="persemon" id="persemon" type="text" class="porcento" value="" />
		<br />
		
		<label for="qtprebem">Parcelas a pagar:</label>
		<input name="qtprebem" id="qtprebem" type="text" class="inteiro" maxlength="3" value="" />
		<br />
		
		<label for="vlprebem">Valor da parcela:</label>
		<input name="vlprebem" id="vlprebem" type="text" maxlength="10" value="" />
		<br />
		
		<label for="vlrdobem">Valor do bem:</label>
		<input name="vlrdobem" id="vlrdobem" type="text" class="moeda" maxlength="17" value="" />
		<br />	
	</form>	
	<div id="divBotoes">
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacaoBens('BR');return false;" />
		<input type="image" name="incluir" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" />
	</div>			
</div>