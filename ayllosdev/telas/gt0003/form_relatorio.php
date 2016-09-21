<?php
/*!
 * FONTE        : form_relatorio.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/09/2013
 * OBJETIVO     : Formulario de relatorio da Tela GT0003
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>
<form id="frmRelatorio" name="frmRelatorio" class="formulario">
	<fieldset>
		<legend>Filtros</legend>
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
		<div id="divRelatorio" >		
		
		<label for="tiporel"><? echo utf8ToHtml('Rel.:') ?></label>
		<select id="tiporel" name="tiporel">
			<option value="yes" selected><? echo utf8ToHtml('Convênio')?> </option>
			<option value="no" ><? echo utf8ToHtml('Cooperativa') ?> </option>		
		</select>
	
		<label for="cdcooper"><? echo utf8ToHtml('Coop.:') ?></label>
		<input id="cdcooper" name="cdcooper" type="text" class="inteiro" maxlength="2" />
						
		<label for="dtinici"><? echo utf8ToHtml('Início:') ?></label>
		<input id="dtinici" name="dtinici" type="text"/>
				
		<label for="dtfinal"><? echo utf8ToHtml('Final:') ?></label>
		<input id="dtfinal" name="dtfinal" type="text"/>
					
		<br style="clear:both" />
		
		</div>
	</fieldset>
</form>