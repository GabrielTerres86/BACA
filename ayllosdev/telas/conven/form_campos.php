<?
/*!
 * FONTE        : form_campos.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/12/2017
 * OBJETIVO     : Campos para a tela CONVEN
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
 */
 
?> 

<div id="divCampos">
<form id="frmCampos" name="frmCampos" class="formulario">
  <fieldset>
        <label for="nmrescon"><? echo utf8ToHtml('Nome Fantasia.:') ?></label>
        <input name="nmrescon" id="nmrescon" type="text" value="" >
        <br style="clear:both" />
        
        <label for="nmextcon"><? echo utf8ToHtml('Razão Social:') ?></label>
        <input name="nmextcon" id="nmextcon" type="text" value="" >
        <br style="clear:both" />
        
        <label for="cdhistor"><? echo utf8ToHtml('Histórico:') ?></label>
        <input name="cdhistor" id="cdhistor" type="text" value="" >
        
        <label for="nrdolote"><? echo utf8ToHtml('Nro.Lote:') ?></label>
        <input name="nrdolote" id="nrdolote" type="text" value="" >
        <br style="clear:both" />
        
        <label for="flginter"><? echo utf8ToHtml('Pagamento na Internet:') ?></label>
        <select id="flginter" name="flginter">        
            <option value="1"> <? echo utf8ToHtml('SIM'); ?></option> 
            <option value="0"> <? echo utf8ToHtml('NÃO'); ?></option> 
        </select>
        <br style="clear:both" />
	</fieldset>    
	
	<br style="clear:both" />

    <fieldset>	
        <input name="tparrecd" id="tparrecd" type="hidden" value="" >
    
        <legend><? echo utf8ToHtml('Forma de arrecadação') ?></legend>
        
        <label style="margin-left:180px"><? echo utf8ToHtml('Aceita') ?></label>
        
        <label style="margin-left:180px"><? echo utf8ToHtml('Arrecada') ?></label>
        
        <br style="clear:both" />
        <label for="flgaccec"><? echo utf8ToHtml('CECRED:') ?></label>
        <input name="flgaccec" id="flgaccec_1" type="radio" class="radio" value="1"   style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="flgaccec_1" class="radio">Sim</label>
        <input name="flgaccec" id="flgaccec_0" type="radio" class="radio" value="0"   style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="flgaccec_0" class="radio"><? echo utf8ToHtml('Não'); ?></label>
        
        <input name="tparrecd_3" id="tparrecd_3" type="radio" class="radio" value="1"  style="height: 20px; margin: 3px 2px 3px 132px !important;"/>
        <label for="tparrecd_3" class="radio">Sim</label>
        <input name="tparrecd_3" id="tparrecd_N3" type="radio" class="radio" value="0" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="tparrecd_N3" class="radio"><? echo utf8ToHtml('Não'); ?></label>
        
        <br style="clear:both" />
        
        <label for="flgacsic"><? echo utf8ToHtml('Convênio SICREDI:') ?></label>
        <input name="flgacsic" id="flgacsic_1" type="radio" class="radio" value="1" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="flgacsic_1" class="radio">Sim</label>                           
        <input name="flgacsic" id="flgacsic_0" type="radio" class="radio" value="0" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="flgacsic_0" class="radio"><? echo utf8ToHtml('Não'); ?></label>
        
        <input name="tparrecd_1" id="tparrecd_1" type="radio" class="radio" value="2"  style="height: 20px; margin: 3px 2px 3px 132px !important;"/>
        <label for="tparrecd_1" class="radio">Sim</label>                             
        <input name="tparrecd_1" id="tparrecd_N1" type="radio" class="radio" value="0" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="tparrecd_N1" class="radio"><? echo utf8ToHtml('Não'); ?></label>
    
        <br style="clear:both" />
        
        <label for="flgacbcb"><? echo utf8ToHtml('Convênio BANCOOB:') ?></label>
        <input name="flgacbcb" id="flgacbcb_1" type="radio" class="radio" value="1" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="flgacbcb_1" class="radio">Sim</label>                           
        <input name="flgacbcb" id="flgacbcb_0" type="radio" class="radio" value="0" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="flgacbcb_0" class="radio"><? echo utf8ToHtml('Não'); ?></label>
        
        <input name="tparrecd_2" id="tparrecd_2" type="radio" class="radio" value="3" style="height: 20px; margin: 3px 2px 3px 132px !important;"/>
        <label for="tparrecd_2" class="radio">Sim</label>                             
        <input name="tparrecd_2" id="tparrecd_N2" type="radio" class="radio" value="0" style="height: 20px; margin: 3px 2px 3px 10px !important;"/>
        <label for="tparrecd_N2" class="radio"><? echo utf8ToHtml('Não'); ?></label>
    
    </fieldset>
    
    <div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>	
		<a href="#" class="botao" id="btnOk"   onClick="confirmaOpe(); return false;">Prosseguir</a>	
	</div>
	
	
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmCampos'));  
</script>	
