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

<div id="tabAssociado" >
	<form id="frmDevolu" name="frmDevolu" class="formulario" onSubmit="return false;" style="display:block" >
			<input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo $nmprimtl;?>" />
	</form>
</div>
