<?
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/12/2017
 * OBJETIVO     : Campos da opcao consulta da tela DEBBAN
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
 */
 
?> 

<div id="divConsulta">
    <form id="frmConsulta" name="frmConsulta" class="formulario">
        <fieldset>
            
            <div class="tabDebitos">

            </div>        
        
            <br style="clear:both" />
            
            <label for="dscooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
            <input name="dscooper" id="dscooper" type="text" value="" >
            
            <label for="nrdocmto"><? echo utf8ToHtml('Documento:') ?></label>
            <input name="nrdocmto" id="nrdocmto" type="text" value="" >
            
            <br style="clear:both" />
            
            <label for="dttransa"><? echo utf8ToHtml('Data Transação:') ?></label>
            <input name="dttransa" id="dttransa" type="text" value="" >
            
            <label for="hrtransa"><? echo utf8ToHtml('Hora Transação:') ?></label>
            <input name="hrtransa" id="hrtransa" type="text" value="" >
            
            <br style="clear:both" />
            
            <label for="dslindig"><? echo utf8ToHtml('Linha Digitavel:') ?></label>
            <input name="dslindig" id="dslindig" type="text" value="" >
            
        </fieldset>    
        
        <div id="divBotoes" style="margin-bottom: 10px;">	
            <a href="#" class="botao" id="btVoltar"     onClick="estadoInicial(); 	return false;">Voltar</a>	            
            <a href="#" class="botao" id="btProsseguir" onClick="confirmaProcess(); 	return false;">Prosseguir</a>	            
        </div>
        
        
    </form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmCampos'));  
</script>	
