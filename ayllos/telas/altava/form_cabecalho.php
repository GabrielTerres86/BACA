<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 21/12/2011
 * OBJETIVO     : Cabeçalho para a tela ALTAVA
 * --------------
 * ALTERAÇÕES   : 21/11/2012 - Alterado botões do tipo campo <input> por
 *				  campo <a> (Daniel).
 * --------------
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none">

	<input name="nrcpfava" id="nrcpfava" type="hidden" value="" />
	<input name="nmdavali" id="nmdavali" type="hidden" value="" />
	<input name="uladitiv" id="uladitiv" type="hidden" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" alt="Informe a Conta/DV ou F7 para pesquisar e clique em OK ou ENTER para prosseguir."/>
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK1" >OK</a>

	<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>
	<input name="nrctremp" id="nrctremp" type="text" alt="Informe o numero do contrato ou F7 para listar e clique em OK ou ENTER para prosseguir."  autocomplete="off" />
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK2" >OK</a>

	<br />
	
	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" />
	
	<br style="clear:both" />	

</form>

