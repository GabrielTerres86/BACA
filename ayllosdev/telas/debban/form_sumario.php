<?
/*!
 * FONTE        : form_sumario.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/12/2017
 * OBJETIVO     : Campos da opcao consulta da tela DEBBAN
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
 */
  
?> 

<div id="divSumario">
    <form id="frmSumario" name="frmSumario" class="formulario">
        <fieldset>
            
            <label for="qtefetiv"><? echo utf8ToHtml('Efetivados:') ?></label>
            <input name="qtefetiv" id="qtefetiv" type="text" value="" >
            <br style="clear:both" />
            
            <label for="qtnefeti"><? echo utf8ToHtml('Não Efetivados:') ?></label>
            <input name="qtnefeti" id="qtnefeti" type="text" value="" >            
            <br style="clear:both" />
            
            <label for="qtpenden"><? echo utf8ToHtml('Pendentes:') ?></label>
            <input name="qtpenden" id="qtpenden" type="text" value="" >
            <br style="clear:both" />
            
            <label for="qttotlan"><? echo utf8ToHtml('Total:') ?></label>
            <input name="qttotlan" id="qttotlan" type="text" value="" >
            
           
        </fieldset>    
        
        <div id="divBotoes" style="margin-bottom: 10px;">	
            <a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>	            
        </div>
        
        
    </form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmCampos'));  
</script>	
