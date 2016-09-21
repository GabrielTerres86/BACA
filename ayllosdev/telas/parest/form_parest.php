<?php
/* !
 * FONTE        : form_parest.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/03/2016 
 * OBJETIVO     : Formulário de exibição da tela PAREST
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>
<form name="frmParest" id="frmParest" class="formulario" style="display:none">		

    <div id="divAlteracao" style="display:none">
        <fieldset>

            <legend><?php echo utf8ToHtml('Parâmetros') ?></legend>
			
			<label for="contigen"><?php echo utf8ToHtml('Habilita Contigência:') ?></label>
			<select id="contigen" name="contigen">
				<option value="1"><? echo utf8ToHtml(' Sim') ?></option> 
				<option value="0"><? echo utf8ToHtml(' Não') ?></option>
			</select>
			
						
			<br style="clear:both" />

            
            
            <label for="incomite"><?php echo utf8ToHtml('Valida envio de e-mail comite sede:') ?></label>
			<select id="incomite" name="incomite">
				<option value="1"><? echo utf8ToHtml(' Sim') ?></option> 
				<option value="0"><? echo utf8ToHtml(' Não') ?></option>
			</select>


            <br style="clear:both" />	

        </fieldset>	
    </div>

</form>

