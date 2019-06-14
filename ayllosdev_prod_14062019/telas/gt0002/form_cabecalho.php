<?
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod(); 
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 19/09/2013
 * OBJETIVO     : Cabeçalho para a tela GT0002
 * --------------
 * ALTERAÇÕES   :
 
 16/05/2016 - #412560 Acentuações das opções, pois está sendo usada a função utf8ToHtml (Carlos)
  
 * --------------
 */
 
 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
				
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="C" selected><? echo utf8ToHtml('C - Consultar convênios por cooperativas')?> </option>
		<option value="E" ><? echo utf8ToHtml('E - Excluir convênios por cooperativas') ?> </option>		
		<option value="I" ><? echo utf8ToHtml('I - Incluir convênios por cooperativas')?> </option>
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
</form>