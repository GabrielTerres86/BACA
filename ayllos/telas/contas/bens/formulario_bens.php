<? 
/*!
 * FONTE        : formulario_bens.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 04/03/2010 
 * OBJETIVO     : Forumlário de dados de Bens para alteracao
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 005: [13/04/2010] Rodolpho Telmo  (DB1): Inserção da propriedade maxlength nos inputs 
 * 006: [19/08/2013] Carlos (CECRED) : Bloqueio do caracter ponto e vírgula (function bloqueiaPontoVirgula) no cadastro de bens.
 * 007: [30/07/2014] Jorge  (CECRED) : Bloqueio do caracter pipe alterado nome de funcao bloqueiaPontoVirgula para bloqueiaChar no cadastro de bens.
 * 008: [28/08/2017] Carlos R. (CECRED) : Correcao das mensagens de Warning log Apache. SD 743183
 */	
?>	

<? $bem = $registros[0]->tags; ?>

<script>
function bloqueiaChar(event) {
	// Essecial para funcionar no IE (window.event = ie) 
	var e = event || window.event;	
	// Verifica se a tecla pressionada consta caracteres restritos
	var charCode = e.which || e.keyCode;
	if ((String.fromCharCode(charCode) == ';') ||
	    (String.fromCharCode(charCode) == '|')){
		if ($.browser.msie) {
		    e.returnValue = false;
		} else {
			e.stopPropagation();
			e.preventDefault(); 
		}
	}
}
</script>
<form name="frmDadosBens" id="frmDadosBens" class="formulario">
	<label for="dsrelbem">Descri&ccedil;&atilde;o do bem:</label>
	<input name="dsrelbem" id="dsrelbem" type="text" class="alphanum" maxlength="40" value="<? echo getByTagName($bem,'dsrelbem'); ?>"
           onKeyPress="bloqueiaChar(event)"       />
	<br />
	
	<label for="persemon">Percentual sem &ocirc;nus:</label>
	<input name="persemon" id="persemon" type="text" class="porcento" value="<? echo number_format(floatval(str_replace(',','.',getByTagName($bem,'persemon'))),2,',','.'); ?>" />
	<br />
	
	<label for="qtprebem">Parcelas a pagar:</label>
	<input name="qtprebem" id="qtprebem" type="text" class="inteiro" maxlength="3" value="<? echo getByTagName($bem,'qtprebem'); ?>" />
	<br />
	
	<label for="vlprebem">Valor da parcela:</label>
	<input name="vlprebem" id="vlprebem" type="text" maxlength="10" value="<? echo number_format(floatval(str_replace(',','.',getByTagName($bem,'vlprebem'))),2,',','.'); ?>" />
	<br />
	
	<label for="vlrdobem">Valor do bem:</label>
	<input name="vlrdobem" id="vlrdobem" type="text" class="moeda" maxlength="17" value="<? echo number_format(floatval(str_replace(',','.',getByTagName($bem,'vlrdobem'))),2,',','.'); ?>" />
	<br />	
</form>	

<div id="divBotoes">
	<? if ( $operacao == 'CA' ) { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC');return false;" />
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="validaBens('AV');" />	
	<? } else if ( $operacao == 'CI' ) { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('IC');return false;" />
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="validaBens('IV');" />	
	<? }else if ( $operacao == 'CF' ) { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="controlaOperacao('');return false;" />
	<?}?>
</div>			