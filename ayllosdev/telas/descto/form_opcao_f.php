<? 
/*!
 * FONTE        : form_opcao_f.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 19/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao F da tela DESCTO
 * --------------
 * ALTERAÇÕES   : 20/06/2017 - Retiradas as linhas Menor e Maior. PRJ367 - Compe Sessao Unica (Lombardi)
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	include('form_cabecalho.php');
	
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<?php include('form_associado.php'); ?>

	<fieldset>
		<legend> Cheques </legend>

		<label for="dslibera">Liberacao para:</label>
		<label for="dtlibera"></label>
		<input type="text" id="dtlibera" name="dtlibera" value="<?php echo $dtlibera ?>" />
		<a href="#" class="botao" id="btnOk2">Ok</a>
		
		<br style="clear:both" /><br />

		<label for="lqtdedas">Qtde.</label>
		<label for="lvalores">Valor</label>
		
		<br />
		
		<label for="dscheque">Cheques Recebidos:</label>
		<label for="qtcheque"></label>
		<input type="text" id="qtcheque" name="qtcheque" value="<?php echo getByTagName($dados,'qtcheque') ?>" />
		<label for="vlcheque"></label>
		<input type="text" id="vlcheque" name="vlcheque" value="<?php echo getByTagName($dados,'vlcheque') ?>" />
		
		<br />
		
		<label for="dschqdev">Cheques Resgatados:</label>
		<label for="qtchqdev"></label>
		<input type="text" id="qtchqdev" name="qtchqdev" value="<?php echo getByTagName($dados,'qtchqdev') ?>" />
		<label for="vlchqdev"></label>
		<input type="text" id="vlchqdev" name="vlchqdev" value="<?php echo getByTagName($dados,'vlchqdev') ?>" />

		<br style="clear:both" /><br />
		
		<label for="dschqcop"><?php echo getByTagName($dados,'dschqcop') ?></label>
		<label for="qtchqcop"></label>
		<input type="text" id="qtchqcop" name="qtchqcop" value="<?php echo getByTagName($dados,'qtchqcop') ?>" />
		<label for="vlchqcop"></label>
		<input type="text" id="vlchqcop" name="vlchqcop" value="<?php echo getByTagName($dados,'vlchqcop') ?>" />

		<br />
		
		<label for="dschqban">Cheques de Outros Bancos:</label>
		<label for="qtchqban"></label>
		<input type="text" id="qtchqban" name="qtchqban" value="<?php echo getByTagName($dados,'qtchqban') ?>" />
		<label for="vlchqban"></label>
		<input type="text" id="vlchqban" name="vlchqban" value="<?php echo getByTagName($dados,'vlchqban') ?>" />

		<br />
		
		<label for="dscredit">Valor a LIBERAR:</label>
		<label for="qtcredit"></label>
		<input type="text" id="qtcredit" name="qtcredit" value="<?php echo getByTagName($dados,'qtcredit') ?>" />
		<label for="vlcredit"></label>
		<input type="text" id="vlcredit" name="vlcredit" value="<?php echo getByTagName($dados,'vlcredit') ?>" />
		
	</fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


