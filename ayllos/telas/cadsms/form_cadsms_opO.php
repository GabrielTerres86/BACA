<?php
/*!
 * FONTE        : form_cadsms.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/10/2016
 * OBJETIVO     : Mostrar campos das opcões 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

?>

<style>
	.ui-datepicker-trigger{
		float:left;
		margin-left:2px;
		margin-top:5px;
	}
</style>

<div id="divOpcaoO">
<form id="frmOpcaoO" name="frmOpcaoO" class="formulario" style="display:block;">

	<br style="clear:both" />	

    <input id="flgenvia_sms" name="flgenvia_sms" type="checkbox" style="margin:0px;margin-top:3px" >
    <label for="flgenvia_sms" class="rotulo-linha" style="padding-left: 5px;"><? echo utf8ToHtml('Cooperativa envia SMS') ?></label>
    
	<br style="clear:both" />	
    
    <input id="flofesms" name="fgofesms" type="checkbox" >
    <label for="flofesms"><? echo utf8ToHtml('Ofertar Servi&ccedil;os') ?></label>
    
    <br style="clear:both" />	
    <br style="clear:both" />
    
	<label for="dtiniofe"><? echo utf8ToHtml('Inicio:') ?></label>
	<input id="dtiniofe" name="dtiniofe" type="text" />

	<label for="dtfimofe"><? echo utf8ToHtml('Fim:') ?></label>
	<input id="dtfimofe" name="dtfimofe" type="text" />
		
	<br style="clear:both" />	
    <br style="clear:both" />	
	
    <fieldset style=" width:700px">
        <legend>Texto para mensagem pop-up do IB</legend>
        <textarea id="dsmensag" name="dsmensag" class="textarea">            
        </textarea>    
    </fieldset>
    
    <br style="clear:both" />	
	<br style="clear:both" />	
    
	<hr style="background-color:#666; height:1px;" />
	
	<div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); 	return false;">Voltar</a>	
		<a href="#" class="botao" id="btnOk" onClick="confirmaOpcaoO(); return false;">Prosseguir</a>	
	</div>
	
</form>
</div>

<script type='text/javascript'>
	highlightObjFocus($('#frmOpcaoO')); 
    
    $.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );	
  
  $(function() {
	  $( "#dtiniofe" ).datepicker({
	  showOn: "button",
	  defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",	
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    }); 
  });
  
  $(function() {
	  $( "#dtfimofe" ).datepicker({
	  showOn: "button",	  
	  defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",	
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    }); 
  });
    
 
</script>
