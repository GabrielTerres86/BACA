<? 
/*!
 * FONTE        : form_grid.php
 * CRIA��O      : Tiago Machado Flor
 * DATA CRIA��O : 22/01/2015 
 * OBJETIVO     : Form com grid das tarifas pendentes
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
 
?>

<?php
 	session_start();
	set_time_limit(999999999);
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmTarpen" name="frmTarpen" style="display:none" class="formulario">
	
		
</form>
