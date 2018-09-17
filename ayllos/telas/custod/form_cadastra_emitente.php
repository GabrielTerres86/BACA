<?
/*!
 * FONTE        : form_cadastra_emitente.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 31/03/2017
 * OBJETIVO     : Form para cadastro de emitentes.
 * --------------
 * ALTERAÇÕES   :
 */		

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');
isPostMethod();		

$cdcmpchq = (isset($_POST['cdcmpchq'])) ? $_POST['cdcmpchq'] : 0;
$cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : 0;
$cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : 0;
$nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0;

?>
<form id="frmCadastraEmitente" name="frmCadastraEmitente" class="formulario" >

	<fieldset>
		<legend align="left">Emitente</legend>

		<label for="cdcmpchq">Comp:</label>
		<input type="text" id="cdcmpchq" name="cdcmpchq" value="<?php echo $cdcmpchq ?>"/>
		
		<label for="cdbanchq">Banco:</label>
		<input type="text" id="cdbanchq" name="cdbanchq" value="<?php echo $cdbanchq ?>"/>

		<label for="cdagechq">Ag&ecirc;ncia:</label>
		<input type="text" id="cdagechq" name="cdagechq" value="<?php echo $cdagechq ?>"/>
		
		<label for="nrctachq">Conta:</label>
		<input type="text" id="nrctachq" name="nrctachq" value="<?php echo $nrctachq ?>"/>
				
		</br>
	</fieldset>
	
	<br style="clear:both" />	
	<label for="nrcpfcgc">CPF/CNPJ:</label>
	<input type="text" id="nrcpfcgc" name="nrcpfcgc" maxlength="18"/>

	</br>
	
	<label for="dsemiten">Nome/Raz&atilde;o Social:</label>
	<input type="text" id="dsemiten" name="dsemiten" maxlength="60"/>
	<br style="clear:both" />		
	<br style="clear:both" />		
	
</form>

<div id="divBotoesDetalhe" style="padding-bottom:10px;">
	<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Voltar</a>
	<a href="#" class="botao" id="btIncluirEmi" onclick="confirmaIncluiEmitente(); return false;">Incluir</a>
</div>