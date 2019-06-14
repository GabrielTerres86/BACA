<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : André Bohn         
 * DATA CRIAÇÃO : 31/08/2018
 * OBJETIVO     : Cabeçalho para a tela PESSOA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */		

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php'); 
    require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<form id="frmCabPessoa" name="frmCabPessoa" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<input type="hidden" id="glbdtmvt" name="glbdtmvt" value="<? echo $glbvars["dtmvtolt"] ?>" />
	
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="M"><? echo utf8ToHtml('M - Manutenção de Cargos e Funções do Cooperado') ?> </option> 
	</select>
	
	<a href="#" class="botao" id="btOK" name="btOK" style = "text-align:right;">OK</a>

	<br style="clear:both" />	
	
</form>