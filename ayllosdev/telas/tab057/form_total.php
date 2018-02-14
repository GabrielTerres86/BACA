<? 
 /*!
 * FONTE        : form_total.php
 * DATA CRIAÇÃO : Jsneiro/2018							 Última Alteração: 
 * OBJETIVO     : Formulário de exibição
 *
 * --------------
 * ALTERAÇÕES   : 
 * --------------			  
 */	
?>

<form name="frmDetalhe" id="frmDetalhe" class="formulario" style="display:block">	    
	<fieldset>
    
        <input type="hidden" id="cdcooper_selec" name="cdcooper_selec" />               
        <input type="hidden" id="cdconven_selec" name="cdconven_selec" />                        
        <input type="hidden" id="dtmvtolt_selec" name="dtmvtolt_selec" />                        
        <input type="hidden" id="nrsequen_selec" name="nrsequen_selec" /> 
    
        <br>
        <label for="nmarquiv"><? echo utf8ToHtml('Arquivo:') ?></label>
        <input id="nmarquiv" name="nmarquiv" type="text"/>
                
        <label for="nrsequen"><? echo utf8ToHtml('Nro. Seq.:') ?></label>
        <input id="nrsequen" name="nrsequen" type="text"/>          

        <label for="dssitret"><? echo utf8ToHtml('Situação:') ?></label>
        <input id="dssitret" name="dssitret" type="text"/>          
        <br>
        
        <div style="width:90%;margin-left:20px">
        <fieldset >
            <legend><? echo utf8ToHtml('Totais') ?></legend>
            
            <label for="qtdoctos"><? echo utf8ToHtml('Qtd.:') ?></label>
            <input name="qtdoctos" id="qtdoctos" type="text" value="<? echo $qttotdoc; ?>" />
            
            <label for="vldoctos"><? echo utf8ToHtml('Arrec.:') ?></label>
            <input name="vldoctos" id="vldoctos" type="text" value="<? echo number_format(str_replace(",",".",$qttotarr),2,",","."); ?>" />
                
            <br />
            <label for="vltarifa"><? echo utf8ToHtml('Tarifa:') ?></label>
            <input name="vltarifa" id="vltarifa" type="text" value="<? echo number_format(str_replace(",",".",$qttottar),2,",","."); ?>" />

            <label for="vlapagar"><? echo utf8ToHtml('Pagar:') ?></label>
            <input name="vlapagar" id="vlapagar" type="text" value="<? echo number_format(str_replace(",",".",$qttotpag),2,",","."); ?>" />
            <br/>
        </fieldset>	
        </div>
    </fieldset>    
</form>

<script type="text/javascript">
  //Labels
  $('label[for="qtdoctos"]','#frmDetalhe').addClass('rotulo').css({'width':'100'});
  $('label[for="vldoctos"]','#frmDetalhe').addClass('rotulo-linha').css({'width':'100'});
  $('label[for="vltarifa"]','#frmDetalhe').addClass('rotulo').css({'width':'100'});
  $('label[for="vlapagar"]','#frmDetalhe').addClass('rotulo-linha').css({'width':'100'});
  
  $('label[for="nmarquiv"]','#frmDetalhe').addClass('rotulo').css({'width':'75'});
  $('label[for="nrsequen"]','#frmDetalhe').addClass('rotulo-linha').css({'width':'75'});
  $('label[for="dssitret"]','#frmDetalhe').addClass('rotulo').css({'width':'75'});
  
  
  //Campos
  $('#qtdoctos','#frmDetalhe').css({'width':'150px','text-align':'right'}).desabilitaCampo();
  $('#vldoctos','#frmDetalhe').css({'width':'150px','text-align':'right'}).desabilitaCampo();
  $('#vltarifa','#frmDetalhe').css({'width':'150px','text-align':'right'}).desabilitaCampo();
  $('#vlapagar','#frmDetalhe').css({'width':'150px','text-align':'right'}).desabilitaCampo();
  
  $('#nmarquiv','#frmDetalhe').css({'width':'245px','text-align':'left'}).desabilitaCampo().addClass('alphanum').attr('maxlength','24');
  $('#nrsequen','#frmDetalhe').addClass('inteiro').css({'width':'95px'}).desabilitaCampo();
  $('#dssitret','#frmDetalhe').addClass('alpha').css({'width':'245px','text-align':'left'}).desabilitaCampo();
  
	
</script>