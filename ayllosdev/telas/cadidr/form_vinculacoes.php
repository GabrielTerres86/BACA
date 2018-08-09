<?
/*!
 * FONTE        	: form_vinculacoes.php
 * CRIAÇÃO      	: André Clemer - Supero
 * DATA CRIAÇÃO 	: Agosto/2018
 * OBJETIVO     	: Form da tela CADIDR
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */ 

?>
<div id="divIndicador">
    <form name="frmCadidr" id="frmCadidr" class="formulario" action="cadidr.php;">
            
		<label for="idvinculacao" class="rotulo" style="width:70px">C&oacute;digo:</label>
		<input name="idvinculacao" class="campo" id="idvinculacao" type="text" value="" disabled />
		</br>
		<label for="nmvinculacao" class="rotulo" style="width:70px">Vincula&ccedil;&atilde;o:</label>
		<input name="nmvinculacao" class="campo" id="nmvinculacao" type="text" maxlength="100" value="" />
		</br>
		<label for="flgativo" class="rotulo" style="width:70px">Ativo:</label>
		<select name="flgativo" id="flgativo" class="campo" >
			<option value="1">Sim</option>
			<option value="0">N&atilde;o</option>
		</select>
		<br style="clear:both">
		<label for="dsvinculacao" class="rotulo" style="width:70px">Descri&ccedil;&atilde;o:</label>
		<textarea class="campo" name="dsvinculacao" id="dsvinculacao" maxlength="400" style="margin-left: 3px; margin-top: 3px; margin-bottom: 10px;"></textarea>
    </form>
</div>
<script type="text/javascript">
    $( function() {
        highlightObjFocus($('#frmCadidr', '#divAba1'));
    });
</script>    
