<?
/*!
 * FONTE        : form_solins.php
 * CRIAÇÃO      : Fabrício
 * DATA CRIAÇÃO : 05/09/2011
 * OBJETIVO     : Conteudo da tela SOLINS
 * --------------
 * ALTERAÇÕES   : 06/07/2012 - Adicionado campo sidlogin em form frmSolins (Jorge).
 * 				  
 *				  09/01/2013 - Layout padrao (Gabriel).
 *
 *                15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 */ 
?>

<form name="frmSolins" id="frmSolins" class="formulario cabecalho" >
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">																				
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td  class="txtNormalBold" style="width: 46px; text-align: right;" >PA:</td>
			<td>
				<input name="cdagenci" type="text" class="campo" id="cdagenci" style="width: 35px;" title="Informe o n&uacute;mero do PA." onChange="limpaBeneficiario();">
				<a id="btBuscaPac"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
			</td>
			<td  class="txtNormalBold" style="text-align: right;" >Benefici&aacute;rio:</td>
			<td>
				<input name="nmbenefi" type="text" class="campo" id="nmbenefi" style="width: 200px;" alt="Informe o nome do benefici&aacute;rio." onChange="mostraBeneficiarios(1,30);">
				<a id="btBuscaBenef"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			</td>
		</tr>
		<tr>
			<td  class="txtNormalBold" style="width: 46px; text-align: right;" >NB:</td>
			<td>
				<input name="nrbenefi" type="text" class="campo" id="nrbenefi" style="width: 100px;">
			</td>
			<td  class="txtNormalBold" style="text-align: right;">NIT:</td>
			<td>
				<input name="nridtrab" type="text" class="campo" id="nridtrab" style="width: 100px;">
			</td>
		</tr>
		<tr></tr>
		<tr></tr>
		<tr>
			<td  class="txtNormalBold" style="width: 46px; text-align: right;">Op&ccedil;&atilde;o:</td>
			<td>
				<select id="cddopcao" name="cddopcao" class='campo' style="width:140px;" onchange="alteraAltMotivo()">
					<option value="1"> 1 - 2ª via de cart&atilde;o </option> 
					<option value="2"> 2 - 2ª via de senha </option>
				</select>
			</td>
			<td class="txtNormalBold" class='campo' style="text-align: right;" >Motivo da Solicita&ccedil;&atilde;o:</td>
			<td>
				<select id="motivsol" name="motivsol" class='campo' style="width:200px;" ></select>
			</td>
		</tr>
	</table>
</form>