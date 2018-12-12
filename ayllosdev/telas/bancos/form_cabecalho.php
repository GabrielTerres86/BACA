<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Cabeçalho para a tela BANCOS
 * --------------
 * ALTERAÇÕES   : 29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *
 *                09/09/2016 - Alterado layout e incluido novos campos: flgoppag, dtaltstr e dtaltpag. 
 *                             PRJ-312 (Reinert)
 * -------------- */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>
<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="A" >A - Alterar os dados das IFs cadastradas</option>
		<option value="C" selected>C - Consultar as IFs cadastradas</option>
		<option value="I" >I - Incluir novo codigo de IF</option>	
		<option value="M" >M - Manuten&ccedil;&atilde;o de IFs cadastrados</option>
	</select>
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
		
	<div id="divEntrada" >
		
		<label for="cdbccxlt"><? echo utf8ToHtml('Banco:') ?></label>
		<input id="cdbccxlt" name="cdbccxlt" type="text"/>
		<a style="padding: 3px 0 0 3px;" id="btLupaBanco" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
	
		<label for="nrispbif"><? echo utf8ToHtml('Número ISPB:') ?></label>
		<input id="nrispbif" name="nrispbif" type="text"/>
		<a style="padding: 3px 0 0 3px;" id="btLupaIspb" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
						
	<br style="clear:both" />
		
	</div>
</form>
