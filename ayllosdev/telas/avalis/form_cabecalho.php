<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)					Última alteração: 10/04/2017
 * DATA CRIAÇÃO : 11/07/2013
 * OBJETIVO     : Cabeçalho para a tela Avalis
 * --------------
 * ALTERAÇÕES   : 21/11/2013 - Removido o F7 devido ao uso do CONTAINS (Guilherme).
 *				  23/07/2015 - Ajuste para incluir a chamada das includes de controle - Jéssica (DB1).
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>
<form id="frmCRM" name="frmCRM" onsubmit="return false;">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	<input type="hidden" name="crm_nrcpfcgc" id="crm_nrcpfcgc" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRCPFCGC']; ?>" />
</form>
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

 