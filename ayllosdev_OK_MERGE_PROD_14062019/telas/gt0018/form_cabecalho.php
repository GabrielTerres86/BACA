<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 12/12/2017
 * OBJETIVO     : Cabeçalho para a tela GT0018
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
 */


?>
<div id="divCab">
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input id="registro" name="registro" type="hidden" value=""  />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" >
		<option value="A" <? echo $cddopcao == 'A' ? 'selected' : '' ?> > <? echo utf8ToHtml('A - Alteração') ?></option> 		
        <option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > <? echo utf8ToHtml('C - Consulta') ?></option> 		       
        <option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> > <? echo utf8ToHtml('I - Inclusão') ?></option> 		    
	</select>
    
    <label for="tparrecd"><? echo utf8ToHtml('Agente:') ?></label>
    <select id="tparrecd" name="tparrecd" >
		<option value="1" <? echo $cddopcao == '1' ? 'selected' : '' ?> > <? echo utf8ToHtml('Sicredi') ?></option> 		
        <option value="2" <? echo $cddopcao == '2' ? 'selected' : '' ?> > <? echo utf8ToHtml('Bancoob') ?></option> 		       
	</select>
    
    <a href="#" class="botao" id="btnOk" onClick="LiberaCampos('frmCab');">OK</a>	
    
    <br style="clear:both" />	
    <div id='divConv'>
    
        <label for="cdempres"><? echo utf8ToHtml('Cod.Convênio:') ?></label>
        <input name="cdempres" id="cdempres" type="text" value="" >
        <a style="margin-top:5px"><img id="lupaConv" name = "lupaConv" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a> 
        <input name="nmextcon" id="nmextcon" type="text" value="" >    
        
    </div>
        
	<br style="clear:both" />	
    
    <div id='divInsert'>
        <label for="cdempcon"><? echo utf8ToHtml('Empresa:') ?></label>
        <input name="cdempcon" id="cdempcon" type="text" value="" >
        <a style="margin-top:5px" tabindex="0 !important" id="linkEmp" name = "linkEmp" ><img id="lupaEmp" name = "lupaEmp" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>        
        <input name="nmrescon" id="nmrescon" type="text" value="" >
        
        <label for="cdsegmto"><? echo utf8ToHtml('Segmento:') ?></label>
        <select id="cdsegmto" name="cdsegmto">    
            
            <option value="0"> </option> 
            
            <option value="1"> <? echo utf8ToHtml('1 - Prefeituras'); ?></option> 
            <option value="2"> <? echo utf8ToHtml('2 - Saneamento'); ?></option> 
            <option value="3"> <? echo utf8ToHtml('3 - Energia Elétria e Gás'); ?></option> 
            <option value="4"> <? echo utf8ToHtml('4 - Telecomunicações'); ?></option> 
            <option value="5"> <? echo utf8ToHtml('5 - Orgãos Governamentais'); ?></option> 
            <option value="6"> <? echo utf8ToHtml('6 - Orgãos identificados através do CNPJ'); ?></option> 
            <option value="7"> <? echo utf8ToHtml('7 - Multas de Trânsito'); ?></option> 
            <option value="9"> <? echo utf8ToHtml('9 - Uso interno do banco'); ?></option> 
        
        </select>
        
        <br style="clear:both" />
    
    </div>
	
</form>
</div>