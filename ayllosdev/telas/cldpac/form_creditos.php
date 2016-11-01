<?php
/*!
 * FONTE        	: form_cheque.php
 * CRIAÇÃO      	: Gabriel Capoia (DB1)
 * DATA CRIAÇÃO 	: 11/01/2013
 * OBJETIVO     	: Formlario nome do arquivo
 * ULTIMA ALTERAÇÃO : 06/06/2016
 * --------------	
 * ALTERAÇÕES   	: 08/07/2013 - Alterado para receber o novo padrão de layout do Ayllos Web. (Reinert)
 *					  
 *					  26/04/2016 - Inclusão da LOV(List of Values) de justificativas conforme solicitado
 *								   no chamado 423093. (Kelvin)
 *
 *					  06/06/2016 - Limitando a quantidade de caracteres nos campos e desabilitando a lov 
 *								   caso não tenha dado dois clicks, conforme solicitado no chamado 461917 
 *								   (Kelvin)
 *
 * --------------
 */ 
?>

<form id="frmCreditos" name="frmCreditos" class="formulario">
	<div id="divCreditos">
		<label for="cddjusti"><? echo utf8ToHtml('Justificativa:') ?></label>
		<input id="cddjusti" name="cddjusti" onChange="buscaJustificativa(); return false;" type="text" maxlength="5"/>
		
		<a id="tbJustificativa" onclick="controlaPesquisa(1); return false;" href="#" style="padding: 3px 0 0 3px;" tabindex="-1">
			<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif">
		</a>		
		
		<label for="dsdjusti"><? echo utf8ToHtml('') ?></label>
		<input id="dsdjusti" name="dsdjusti" type="text" maxlength="1000"/>
		
		<br style="clear:both" />
	
		<label for="dsobserv" ><? echo utf8ToHtml('Comp.Justi.:') ?> </label>
		<input id="dsobserv" name="dsobserv" type= "text" maxlength="1000"/>
	</div>
	
</form>
</fieldset>
</form>