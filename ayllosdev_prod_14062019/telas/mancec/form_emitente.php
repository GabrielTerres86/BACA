<?php
/*!
 * FONTE        : form_emitente.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 18/10/2016
 * OBJETIVO     : Form com os dados da tela MANCEC
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

<form id="frmEmitente" name="frmEmitente" class="formulario" style="display:none">

<br style="clear:both" />	

<fieldset style="padding-bottom:10px">
	<legend><? echo utf8ToHtml('Consulta do Emitente') ?></legend>

	<label for="cdcmpchq"><? echo utf8ToHtml('Compe:') ?></label>
	<input type="text" id="cdcmpchq" name="cdcmpchq" tabindex="3" />	


	<label for="cdbanchq"><? echo utf8ToHtml('Banco:') ?></label>
	<input type="text" id="cdbanchq" name="cdbanchq" tabindex="4" />	

	<label for="cdagechq"><? echo utf8ToHtml('Agencia:') ?></label>
	<input type="text" id="cdagechq" name="cdagechq" tabindex="5" />	


	<label for="nrctachq"><? echo utf8ToHtml('Conta:') ?></label>
	<input type="text" id="nrctachq" name="nrctachq" tabindex="6" />	
	<br style="clear:both" />	
</fieldset>

<div id="divDadosEmitente" style="display:none;">
<fieldset style="padding-bottom:10px">
<legend><? echo utf8ToHtml('Dados do Emitente') ?></legend>

<label for="nmemichq"><? echo utf8ToHtml('Nome do Emitente:') ?></label>
<input type="text" id="nmemichq" name="nmemichq" tabindex="7" />	


<label for="nrcpfchq"><? echo utf8ToHtml('CPF/CNPJ do Emitente:') ?></label>
<input type="text" id="nrcpfchq" name="nrcpfchq" tabindex="8" />	

<br style="clear:both" />	
</fieldset>
</div>



<div id="divBotoes" style="margin-bottom:10px;display:none" >
	<a href="#" class="botao" name="btVoltar" id="btVoltar" onclick="btnVoltar(); return false;" tabindex="9" >Voltar</a>
    <a href="#" class="botao" id="btConsultar" onclick="buscaEmitente(); return false;" tabindex="10" >Prosseguir</a>
</div>

</div>