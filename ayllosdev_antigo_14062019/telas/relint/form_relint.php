<? 
/*!
 * FONTE        : form_relint.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 24/07/2013 
 * OBJETIVO     : Form da tela RELINT
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>


<form id="frmRelint" name="frmRelint" style="display:none" class="formulario" onsubmit="return false;">
	<fieldset>
	<legend>Informe o n&uacute;mero do PA</legend>
	<table width="100%">
		<tr>		
			<td>
				<label for="cdagenci">PA:</label>
				<input type="text" id="cdagenci" name="cdagenci" value="<? echo $cdagenci ?>" />&nbsp;&nbsp;
				<span style="font-style:italic;font-size:10px;vertical-align:-8px;"> * Informe "0" para listar de todos os PA's.</span>
				
			</td>
		</tr>
		<tr>		
			<td id="tr_nmarqtel" style="display:none;">
				<label for="nmarqtel">Nome do arquivo:</label>
				<input type="text" id="nmarqtel" name="nmarqtel" value="<? echo $nmarqtel ?>" />&nbsp;&nbsp;
				<span style="font-style:italic;font-size:10px;vertical-align:-8px;"> * Informe o nome do arquivo a ser gerado.</span>
				
			</td>
		</tr>
	</table>
	</fieldset>
</form>
