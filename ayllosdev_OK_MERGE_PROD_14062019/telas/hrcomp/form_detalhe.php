<?
/*!
 * FONTE        : form_detalhe.php
 * CRIAÇÃO      : Tiago Machado         
 * DATA CRIAÇÃO : 25/02/2014
 * OBJETIVO     : Detalhe para a tela HRCOMP
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

<form id="frmDet" name="frmDet" class="formulario detalhe" onSubmit="return false;" style="display:none">
	<table width="100%">
        <tr>		
			<td>
				<label for="cdcoopex"><? echo utf8ToHtml('Cooperativa:') ?></label>
				<select id="cdcoopex" name="cdcoopex">
					<option value=""></option> 
				</select>				
			</td>
		</tr>		
		<tr>
			<td>
				<div id="divProcessos" name="divProcessos"></div>
			</td>
		</tr>
	</table>
</form>