<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 10/06/2011
 * OBJETIVO     : Cabeçalho para a tela DCTROR
 * --------------
 * ALTERAÇÕES   : 11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
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
		<option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> > I </option>
		<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > C </option> 
		<option value="A" <? echo $cddopcao == 'A' ? 'selected' : '' ?> > A </option>
		<option value="E" <? echo $cddopcao == 'E' ? 'selected' : '' ?> > E </option>
	</select>
	
	<label for="tptransa"><? echo utf8ToHtml('Tipo:') ?></label>
	<select id="tptransa" name="tptransa">
		<option value="0">--</option> 
		<option value="1" <? echo $tptransa == '1' ? 'selected' : '' ?> > 1 - Bloqueio </option> 
		<option value="2" <? echo $tptransa == '2' ? 'selected' : '' ?> > 2 - Contra-ordem/Aviso </option>
		<option value="3" <? echo $tptransa == '3' ? 'selected' : '' ?> > 3 - Prejuizo </option>
	</select>

	<br style="clear:both" />

	<label for="nrdconta">&nbsp;&nbsp;&nbsp;Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" alt="Informe o numero da conta do cooperado." />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input type="image" src="<?php echo $UrlImagens; ?>/botoes/ok.gif">
	
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo getByTagName($registros[0]->tags,'nmprimtl') ?>" />
			
	<br style="clear:both" />
	
</form>