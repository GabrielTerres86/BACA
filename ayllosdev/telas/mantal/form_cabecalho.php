<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 21/06/2011
 * OBJETIVO     : Cabeçalho para a tela MANTAL
 * --------------
 * ALTERAÇÕES   : 04/11/2017 - Ajuste para tela ser chamada atraves da tela CONTAS > IMPEDIMENTOS (Jonata - RKAM P364)
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */ 
?>
<form id="frmCRM" name="frmCRM" onsubmit="return false;">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
</form>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onsubmit="return false;">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="B" <? echo $cddopcao == 'B' ? 'selected' : '' ?> > B </option>
		<option value="D" <? echo $cddopcao == 'D' ? 'selected' : '' ?> > D </option> 
	</select>
	
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" alt="Informe o numero da conta do cooperado." />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK">Ok</a>
	
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo getByTagName($registros[0]->tags,'nmprimtl') ?>" />
			
	<br style="clear:both" />	
	
</form>