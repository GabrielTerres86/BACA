<?php
	/***********************************************************************************************
  Fonte        : form_cabecalho.php
  Criação      : Adriano
  Data criação : Maio/2013
  Objetivo     : Cabeçalho para a tela INSS
  --------------
	Alterações   : 20/10/2015 - Adicionado opção para consultar log Projeto 255 (Lombardi).
				   03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
                   11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
  --------------
	**********************************************************************************************/ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmCabInss" name="frmCabInss" class="formulario cabecalho" style="display:none;">	
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	<input type="hidden" name="crm_nrcpfcgc" id="crm_nrcpfcgc" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRCPFCGC']; ?>" />
		
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" >
		<option value="C" selected> C - Consultar </option>
		<option value="D"> D - Demonstrativo </option>
		<option value="T"> T - Troca de OP </option>
		<option value="R"> R - Relat&oacute;rios </option>		
		<option value="L"> L - Log </option>
	</select>
	
	<a href="#" class="botao" id="btOK"  style="text-align: right;">OK</a>
		
	<br style="clear:both" />	

</form>