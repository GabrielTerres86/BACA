<?php
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Formulário tela DEVOLU
 * --------------
 * ALTERAÇÕES   :  01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *                 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923)
 *                 11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
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
