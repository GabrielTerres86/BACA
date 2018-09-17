<?
/*!
 * FONTE        	: form_cadidr.php
 * CRIAÇÃO      	: Lucas Reinert
 * DATA CRIAÇÃO 	: Fevereiro/2016
 * OBJETIVO     	: Form da tela CADIDR
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */ 

?>
<div id="divIndicador">
    <form name="frmIndicador" id="frmIndicador" class="formulario" action="cadidr.php;">
            
		<label for="idindica">C&oacute;digo:</label>
		<input name="idindica" class="campo" id="idindica" type="text" value="" disabled />
		</br>
		<label for="nmindica">Indicador:</label>
		<input name="nmindica" class="campo" id="nmindica" type="text" maxlength="100" value="" />
		</br>
		<label for="tpindica">Tipo:</label>		
		<select name="tpindica" id="tpindica" class="campo" >
			<option value="Q">Quantidade</option>
			<option value="M">Moeda</option>
			<option value="A">Ades&atilde;o</option>
		</select>			
		<label for="flgativo">Ativo:</label>
		<select name="flgativo" id="flgativo" class="campo" >
			<option value="1">Sim</option>
			<option value="0">N&atilde;o</option>
		</select>
		</br>
		<label for="dsindica">Descri&ccedil;&atilde;o:</label>
		<textarea class="campo" name="dsindica" id="dsindica" maxlength="400" style="margin-left: 3px; margin-top: 3px; margin-bottom: 10px;"></textarea>
    </form>
</div>
<script type="text/javascript">
    $( function() {
        highlightObjFocus($('#frmIndicador'));
    });
</script>    
