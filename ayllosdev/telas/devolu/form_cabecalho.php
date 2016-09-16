<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Formulário tela DEVOLU
 * --------------
 * ALTERAÇÕES   :
 *					   
 * --------------
 */
 ?>
 
 <?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width ="100%">
		<tr>		
			<td> 
				<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
                <input name="nrdconta" id="nrdconta" type="text" value="<? echo $nrdconta ?>" />
                <input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $nmprimtl ?>" />    
			</td>
		</tr>
	</table>
</form>
<br style="clear:both" />
<div id="divResultado" style="display:block;">
</div>
