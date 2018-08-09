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
    <form name="frmCadidr" id="frmCadidr" class="formulario" action="cadidr.php;">
            
		<label for="idindica" class="rotulo" style="width:70px">C&oacute;digo:</label>
		<input name="idindica" class="campo" id="idindica" type="text" value="" disabled />
		</br>
		<label for="nmindica" class="rotulo" style="width:70px">Indicador:</label>
		<input name="nmindica" class="campo" id="nmindica" type="text" maxlength="100" value="" />
		</br>
		<label for="tpindica" class="rotulo" style="width:70px">Tipo:</label>		
		<select name="tpindica" id="tpindica" class="campo" >
			<option value="Q">Quantidade</option>
			<option value="M">Moeda</option>
			<option value="A">Ades&atilde;o</option>
		</select>			
		<label for="flgativo" class="rotulo-linha" style="width:173px">Ativo:</label>
		<select name="flgativo" id="flgativo" class="campo" >
			<option value="1">Sim</option>
			<option value="0">N&atilde;o</option>
		</select>
		</br>
		<label for="dsindica" class="rotulo" style="width:70px">Descri&ccedil;&atilde;o:</label>
		<textarea class="campo" name="dsindica" id="dsindica" maxlength="400" style="margin-left: 3px; margin-top: 3px; margin-bottom: 10px;"></textarea>
    </form>
</div>
<script type="text/javascript">
    $( function() {
        highlightObjFocus($('#frmCadidr', '#divAba0'));
    });
</script>    
