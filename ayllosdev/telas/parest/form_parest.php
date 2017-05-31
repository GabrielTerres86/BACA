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
			
            <label for="nmregmpf">Regra An&aacute;lise Autom&aacute;tica PF:</label>
			<input type="text" id="nmregmpf" name="nmregmpf" title="Somente letras, n&uacute;meros e '_' neste campo">
      
      <br style="clear:both" />	
			
            <label for="nmregmpj">Regra An&aacute;lise Autom&aacute;tica PJ:</label>
			<input type="text" id="nmregmpj" name="nmregmpj" title="Somente letras, n&uacute;meros e '_' neste campo">
			
            <br style="clear:both" />	
			
            <label for="qtsstime">Timeout An&aacute;lise Autom&aacute;tica:</label>
			<input type="text" id="qtsstime" name="qtsstime">
			<label class="rotulo-linha">segundos</label>
			
            <br style="clear:both" />	
			
            <label class="rotulo" style="width:300px">Quantidade de meses para:</label>
			
			<br style="clear:both" />	

            <label for="qtmeschq">Dev. Cheques:</label>
			<input type="text" id="qtmeschq" name="qtmeschq">
			
            <br style="clear:both" />	
			
            <label for="qtmesest">Estouros:</label>
			<input type="text" id="qtmesest" name="qtmesest">
			
            <br style="clear:both" />	
			
            <label for="qtmesemp">Atraso Empr&eacute;stimos:</label>
			<input type="text" id="qtmesemp" name="qtmesemp">
			
            <br style="clear:both" />	

        </fieldset>	
    </div>

</form>

