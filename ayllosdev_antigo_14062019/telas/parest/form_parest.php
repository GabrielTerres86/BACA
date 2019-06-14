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

          <legend><?php echo utf8ToHtml('Parâmetros da Esteira de Crédito') ?></legend>
        
          <label for="contigen"><?php echo utf8ToHtml('Habilita Contingência:') ?></label>
          <select id="contigen" name="contigen">
            <option value="1"><? echo utf8ToHtml(' Sim') ?></option> 
            <option value="0"><? echo utf8ToHtml(' Não') ?></option>
          </select>
        
          <br style="clear:both" />

          <label for="incomite"><?php echo utf8ToHtml('Valida Envio de E-mail Comitê Sede:') ?></label>
          <select id="incomite" name="incomite">
            <option value="1"><? echo utf8ToHtml(' Sim') ?></option> 
            <option value="0"><? echo utf8ToHtml(' Não') ?></option>
          </select>
          
          <br style="clear:both" />	
          
          <label for="anlautom"><?php echo utf8ToHtml('Análise Automática da Esteira:') ?></label>
          <select id="anlautom" name="anlautom">
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
        
          <label class="rotulo" style="width:300px">Quantidade de Meses Para:</label>
        
          <br style="clear:both" />	

          <label for="qtmeschq">Dev. Cheques:</label>
          <input type="text" id="qtmeschq" name="qtmeschq">
        
          <label for="qtmeschqal11">Dev. Cheques al. 11:</label>
          <input type="text" id="qtmeschqal11" name="qtmeschqal11">
		  
          <label for="qtmeschqal12">Dev. Cheques al. 12:</label>
          <input type="text" id="qtmeschqal12" name="qtmeschqal12">
        
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

<form name="frmParest04" id="frmParest04" class="formulario" style="display:none">		

    <div id="divAlteracao04" style="display:none">
        <fieldset>

          <legend><?php echo utf8ToHtml('Parâmetros da Esteira de Crédito - Cartão') ?></legend>
          
          <input type="hidden" id="cdcooper" name="cdcooper">
          <input type="hidden" id="nmrescop" name="nmrescop">

          <label style="width: 300px; " for="contigen"><?php echo utf8ToHtml('Habilita Contigência:') ?></label>
          <select id="contigen" name="contigen">
            <option value="<? echo utf8ToHtml('SIM') ?>"><? echo utf8ToHtml(' Sim') ?></option> 
            <option value="<? echo utf8ToHtml('NAO') ?>"><? echo utf8ToHtml(' Não') ?></option>
          </select>
        
          <br style="clear:both" />

          <label style="width: 300px; " for="anlautom"><?php echo utf8ToHtml('Analise Automática da Esteira:') ?></label>
          <select id="anlautom" name="anlautom">
            <option value="SIM"><? echo utf8ToHtml(' Sim') ?></option> 
            <option value="<? echo utf8ToHtml('NAO') ?>"><? echo utf8ToHtml(' Não') ?></option>
          </select>
          
          <br style="clear:both" class="nparaTodos"/>	
        
          <label style="width: 300px; " for="nmregmpf" class="nparaTodos">Regra An&aacute;lise  Autom&aacute;tica PF:</label>
          <input type="text" id="nmregmpf" name="nmregmpf" class="campo nparaTodos" title="Somente letras, n&uacute;meros e '_' neste campo">
        
          <br style="clear:both" class="nparaTodos"/>	
		  
		  <label style="width: 300px; " for="nmregmpf" class="nparaTodos">Regra An&aacute;lise  Autom&aacute;tica PJ:</label>
          <input type="text" id="nmregmpj" name="nmregmpj" class="campo nparaTodos" title="Somente letras, n&uacute;meros e '_' neste campo">
        
          <br style="clear:both" class="nparaTodos"/>	

          <label style="width: 300px; " for="qtsstime" class="nparaTodos">Timeout Motor:</label>
          <input type="text" id="qtsstime" name="qtsstime" class="campo nparaTodos">
          <label class="rotulo-linha nparaTodos" >segundos</label>
        
          <br style="clear:both"class="nparaTodos" />	    
          <label class="rotulo nparaTodos" style="width:300px" >Quantidade de meses para:</label>        
          <br style="clear:both" class="nparaTodos"/>	

          <label class="nparaTodos" style="width: 50px; " for="qtmeschq">Dev. Cheques:</label>
          <input type="text" id="qtmeschq" name="qtmeschq" class="campo nparaTodos">

          <label class="nparaTodos" style="width: 50px; " for="qtmeschqal11">Dev. Cheques al. 11:</label>
          <input type="text" id="qtmeschqal11" name="qtmeschqal11" class="campo nparaTodos">

          <label class="nparaTodos" style="width: 50px; " for="qtmeschqal12">Dev. Cheques al. 12:</label>
          <input type="text" id="qtmeschqal12" name="qtmeschqal12" class="campo nparaTodos">
        
          <br style="clear:both" class="nparaTodos"/>	
        
          <label style="width: 300px; " for="qtmesest" class="nparaTodos">Estouros:</label>
          <input type="text" id="qtmesest" name="qtmesest" class="campo nparaTodos">
        
          <br style="clear:both" class="nparaTodos"/>	
        
          <label style="width: 300px; " for="qtmesemp" class="nparaTodos" >Atraso Empr&eacute;stimos:</label>
          <input type="text" id="qtmesemp" name="qtmesemp" class="campo nparaTodos">
        
          <br style="clear:both" />	

        </fieldset>	
    </div>

</form>

