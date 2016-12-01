<?php
/*!
 * FONTE        : DEVOLU.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : 25/09/2013
 * OBJETIVO     : Formul�rio tela DEVOLU
 * --------------
 * ALTERA��ES   :  01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *                 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923)
 * --------------
 */
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
			    <label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
                <input name="cdagenci" id="cdagenci" type="text" value="<? echo $cdagenci ?>" />

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
