<? 
/*!
 * FONTE        : formulario_bens_proc.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 20/03/2014 
 * OBJETIVO     : Forumlário de dados de Bens para alteracao
 *
 * ALTERACOES   : 001: [05/09/2012] Mudar para layout padrao (Gabriel) 
                  002: [19/08/2013] Bloqueio do caracter ponto e vírgula (function bloqueiaPontoVirgula) no cadastro de bens (Carlos)
				  003: [20/03/2014] Inclusao do campo idseqbem (Carlos)
				  004: [30/07/2014] Bloqueio do caracter pipe alterado nome de funcao bloqueiaPontoVirgula para bloqueiaChar no cadastro de bens. (Jorge)
 */	
?>	

<? $bem = $regBens[0]->tags; ?>
<script>
function bloqueiaChar(event) {
	// Essecial para funcionar no IE (window.event = ie) 
	var e = event || window.event;	
	// Verifica se a tecla pressionada é ponto e vírgula (;)
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
<div id="divProcBensFormulario">
	<form name="frmProcBens" id="frmProcBens" class="formulario">
		<label for="dsrelbem">Descri&ccedil;&atilde;o do bem:</label>
		<input name="dsrelbem" id="dsrelbem" type="text" class="alphanum" maxlength="40" value="" 
		       onKeyPress="bloqueiaChar(event)" />
	    <input type="hidden" id="idseqbem" name="idseqbem" value="" />
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
		<a href="#" class="botao" id="btVoltar"  onClick="controlaOperacaoBens('BR');return false;" >Cancelar</a>
		<a href="#" class="botao" id="btSalvar" >Concluir</a>		
	</div>			
</div>

<script>
	
	$(document).ready(function() {
	
		 highlightObjFocus($('#frmProcBens'));
	});
	
</script>