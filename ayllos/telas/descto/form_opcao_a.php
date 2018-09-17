<? 
/*!
 * FONTE        : form_opcao_a.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 20/01/2012 
 * OBJETIVO     : Formulario que apresenta a consulta da opcao A da tela DESCTO
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

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<fieldset>
		<legend> Associado </legend>	
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		
	</fieldset>		


	<fieldset>
		<legend> Dados do Cheque </legend>

		<label for="nrborder">Bordero:</label>
		<input type="text" id="nrborder" name="nrborder" value="<?php echo $nrborder ?>"/>
		
		<label for="cdcmpchq">Comp.:</label>
		<input type="text" id="cdcmpchq" name="cdcmpchq" value="<?php echo $cdcmpchq ?>"/>
		
		<label for="cdbanchq">Banco:</label>
		<input type="text" id="cdbanchq" name="cdbanchq" value="<?php echo $cdbanchq ?>"/>

		<label for="cdagechq">Agencia:</label>
		<input type="text" id="cdagechq" name="cdagechq" value="<?php echo $cdagechq ?>"/>

		<label for="nrctachq">Conta:</label>
		<input type="text" id="nrctachq" name="cdagechq" value="<?php echo $nrctachq ?>"/>

		<label for="nrcheque">Nr Cheque:</label>
		<input type="text" id="nrcheque" name="cdagechq" value="<?php echo $nrcheque ?>"/>
		
		<br style="clear:both" /><br />

		<input type="hidden" id="auxnrcpf" name="auxnrcpf" value="<?php echo getByTagName($dados,'nrcpfcgc') ?>"/>
		<input type="hidden" id="auxnmchq" name="auxnmchq" value="<?php echo getByTagName($dados,'nmcheque') ?>"/>

		<label for="nrcpfcgc">CPF/CNPJ:</label>
		<input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo getByTagName($dados,'nrcpfcgc') ?>"/>

		<label for="nmcheque">Nome:</label>
		<input type="text" id="nmcheque" name="nmcheque" value="<?php echo getByTagName($dados,'nmcheque') ?>" />
		
	</fieldset>

</form>


<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


