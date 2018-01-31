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
  
        <legend><? echo utf8ToHtml('Convênio') ?></legend>
  
        <label for="cdempcon"><? echo utf8ToHtml('Empresa:') ?></label>
        <input name="cdempcon" id="cdempcon" type="text" value="" >
        <a style="margin-top:5px"><img id="lupaEmp" name = "lupaEmp" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>        
        <input name="nmrescon" id="nmrescon" type="text" value="" >
        
        <label for="cdsegmto"><? echo utf8ToHtml('Segmaneto:') ?></label>
        <select id="cdsegmto" name="cdsegmto">    
        
            <option value="1"> <? echo utf8ToHtml('1 - Prefeituras'); ?></option> 
            <option value="2"> <? echo utf8ToHtml('2 - Saneamento'); ?></option> 
            <option value="3"> <? echo utf8ToHtml('3 - Energia Eletria e Gas'); ?></option> 
            <option value="4"> <? echo utf8ToHtml('4 - Telecomunicacoes'); ?></option> 
            <option value="5"> <? echo utf8ToHtml('5 - Orgaos Governamentais'); ?></option> 
            <option value="6"> <? echo utf8ToHtml('6 - Orgaos identificados atraves do CNPJ'); ?></option> 
            <option value="7"> <? echo utf8ToHtml('7 - Multas de Transito'); ?></option> 
            <option value="9"> <? echo utf8ToHtml('9 - Uso interno do banco'); ?></option> 
        
        </select>
        
        <br style="clear:both" />
    
	</fieldset>    
	
	<br style="clear:both" />

    <fieldset>	
        <legend><? echo utf8ToHtml('Arrecadação') ?></legend>
        
        <label for="vltarint"><? echo utf8ToHtml('Valor Tarifa Internet:') ?></label>
        <input name="vltarint" id="vltarint" type="text" value="" >
        
        <label for="vltartaa"><? echo utf8ToHtml('Valor Tarifa TAA:') ?></label>
        <input name="vltartaa" id="vltartaa" type="text" value="" >
        
        <br style="clear:both" />
        
        <label for="vltarcxa"><? echo utf8ToHtml('Valor Tarifa Caixa:') ?></label>
        <input name="vltarcxa" id="vltarcxa" type="text" value="" >
        
        <label for="vltardeb"><? echo utf8ToHtml('Valor Tarifa Déb. Automático:') ?></label>
        <input name="vltardeb" id="vltardeb" type="text" value="" >
        
        <br style="clear:both" />
        
        <div id='divCampoSicredi'>
            <label for="vltarcor"><? echo utf8ToHtml('Valor Tarifa Corresp. Bancario:') ?></label>
            <input name="vltarcor" id="vltarcor" type="text" value="" >
            
            <label for="vltararq"><? echo utf8ToHtml('Valor Tarifa Arquivo(CNAB 240):') ?></label>
            <input name="vltararq" id="vltararq" type="text" value="" >
            
            <br style="clear:both" />
        </div>
        
        <label for="nrrenorm"><? echo utf8ToHtml('Dias de Float:') ?></label>
        <input name="nrrenorm" id="nrrenorm" type="text" value="" >
        
        <label for="nrtolera"><? echo utf8ToHtml('Dias de Tolerância Após Vencimento:') ?></label>
        <input name="nrtolera" id="nrtolera" type="text" value="" >
        
        <br style="clear:both" />
        
        <label for="dsdianor"><? echo utf8ToHtml('Forma de Repasse:') ?></label>        
        <select id="dsdianor" name="dsdianor">            
            <option value="U"> <? echo utf8ToHtml('U - Úteis'); ?></option> 
            <option value="C"> <? echo utf8ToHtml('C - Corridos'); ?></option>
        </select>
        
        <label for="dtcancel"><? echo utf8ToHtml('Data de Cancelamento:') ?></label>
        <input name="dtcancel" id="dtcancel" type="text" value="" >
        
        <br style="clear:both" />
        
        <label for="nrlayout" class="Bancoob" ><? echo utf8ToHtml('Layout Febraban:') ?></label>
        <input name="nrlayout" id="nrlayout" type="text" value="" class="Bancoob" >
    
    </fieldset>
    
</form>
<div id="divBotoes" style="margin-bottom: 10px;">	
    <a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>	
    <a href="#" class="botao" id="btnPross" onClick="confirmaOpe(); return false;">Prosseguir</a>	
</div>

</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmCampos'));  
</script>	
