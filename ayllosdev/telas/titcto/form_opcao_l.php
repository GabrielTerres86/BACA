<? 
/*!
 * FONTE        : form_opcao_l.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 14/03/2018
 * OBJETIVO     : Formulario que apresenta a consulta da opcao F da tela TITCTO
 * --------------
 * ALTERAÇÕES   : 
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

<form id="frmOpcao" class="formulario">

	<input type="hidden" id="cddopcao" name="cddopcao" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<fieldset>
		<legend> <? echo utf8ToHtml('Relatório'); ?> </legend>

		<label for="dtvencto"><? echo utf8ToHtml('Listar os lotes do dia:'); ?></label>
		<input type="text" id="dtvencto" name="dtvencto" value="<?php echo $dtvencto ?>" />

		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo $cdagenci ?>" />

	</fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


<?php 
    // Forms com os dados para fazer a chamada da geração de PDF    
    include("impressao_form_l.php");
?>