<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jéssica (DB1)						Última alteração: 02/09/2015
 * DATA CRIAÇÃO : 30/07/2013
 * OBJETIVO     : Cabeçalho para a tela ESTOUR
 * --------------
 * ALTERAÇÕES   : 02/09/2015 - Ajuste para correção da conversão realizada pela DB1
					     	   (Adriano).
 
 */
	
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
				
	<label for="nrdconta"><? echo utf8ToHtml('Conta/DV:') ?></label>
	<input id="nrdconta" name="nrdconta" type="text"/>
	
	<input id="nmprimtl" name="nmprimtl" type="text"/>
	
	<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:left;">OK</a>
	
	<label for="qtddtdev"><? echo utf8ToHtml('Estouro:') ?></label>
	<input id="qtddtdev" name="qtddtdev" type="text"/>
	
	<label for="dd"><? echo utf8ToHtml('DD') ?></label>	
	
	<br style="clear:both" />
	
</form>


