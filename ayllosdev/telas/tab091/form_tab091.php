<?
/**********************************************************************************
  FONTE            : form_cabecalho.php
  CRIAÇÃO          : Adriano
  DATA CRIAÇÃO     : Agosto/2011
  OBJETIVO         : Cabeçalho para a tela TAB091
  Última Alteração : 18/02/2013 
  --------------
  ALTERAÇÕES   : 18/02/2013 - Realizado a inclusão de mais dois e-mail's.
							  Projeto Cadastro Restritivo (Adriano).  
  --------------
 ***********************************************************************************/ 
?>

<form id="frmTab091" name="frmTab091" class="formulario" style="display:none;">	

	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
	    
		<legend> <? echo utf8ToHtml('Par&acirc;metros'); ?> </legend>
					
		<label for="dsemail1"><? echo utf8ToHtml('E-mail 1:') ?></label>
		<input name="dsemail1" id="dsemail1" type="text" value="<? echo $dsdemail[0] ?>" />
		
		<br />
		
		<label for="dsemail2"><? echo utf8ToHtml('E-mail 2:') ?></label>
		<input name="dsemail2" id="dsemail2" type="text" value="<? echo $dsdemail[1] ?>" />
		
		<br />
		
		<label for="dsemail3"><? echo utf8ToHtml('E-mail 3:') ?></label>
		<input name="dsemail3" id="dsemail3" type="text" value="<? echo $dsdemail[2] ?>" />
		
		<br />
			
		<label for="dsemail4"><? echo utf8ToHtml('E-mail 4:') ?></label>
		<input name="dsemail4" id="dsemail4" type="text" value="<? echo $dsdemail[3] ?>" />
		
		<br />
			
		<label for="dsemail5"><? echo utf8ToHtml('E-mail 5:') ?></label>
		<input name="dsemail5" id="dsemail5" type="text" value="<? echo $dsdemail[4] ?>" />

	</fieldset>
		
	<br style="clear:both" />
	
</form>