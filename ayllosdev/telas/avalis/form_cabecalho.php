<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)					Última alteração: 29/07/2016
 * DATA CRIAÇÃO : 11/07/2013
 * OBJETIVO     : Cabeçalho para a tela Avalis
 * --------------
 * ALTERAÇÕES   : 21/11/2013 - Removido o F7 devido ao uso do CONTAINS (Guilherme).		
 *				  23/07/2015 - Ajuste para incluir a chamada das includes de controle - Jéssica (DB1).
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
				
	
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	
	<label for="nrdconta">Conta/dv:</label>
	<input id="nrdconta" name="nrdconta" type="text">
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	<label for="nmprimtl">Titular:</label>
	<input id="nmprimtl" name="nmprimtl" type="text" >
	
	<br style="clear:both" />	
	
	<label for="nrcpfcgc">CPF:</label>
	<input id="nrcpfcgc" name="nrcpfcgc" type="text" >
	
	<?php 
	/* Removido o F7 devido ao uso do CONTAINS na busca de avalistas
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>*/?>
		
	<br style="clear:both" />		
	
</form>

 