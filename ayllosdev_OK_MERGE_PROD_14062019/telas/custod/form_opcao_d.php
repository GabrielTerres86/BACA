<? 
/*!
 * FONTE        : form_opcao_d.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 02/02/2012 
 * OBJETIVO     : Formulário que apresenta a opcao D da tela CUSTOD
 * --------------
 * ALTERAÇÕES   : 01/10/2013 - Alteração da sigla PAC para PA (Carlos).
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
	<input type="hidden" id="protocolo" name="protocolo" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<fieldset>
		<legend> Associado </legend>	
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="nmprimtl">Titular:</label>
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />

		<label for="dtlibera">Liberacao p/:</label>
		<input type="text" id="dtlibera" name="dtlibera" value="<?php echo $dtlibera ?>"/>
		
	</fieldset>		

	<fieldset>
		<legend> Protocolo </legend>	
		
		<label for="dtmvtolt">Data:</label>
		<input type="text" id="dtmvtolt" name="dtmvtolt" value="<?php echo $dtmvtolt ?>"/>
		
		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo $cdagenci ?>" />
		
		<label for="bcocxa12">Bco/Cxa:</label>
		<input type="text" id="bcocxa12" name="bcocxa12" value="600"/>

		<label for="nrdolote">Lote:</label>
		<input type="text" id="nrdolote" name="nrdolote" value="<?php echo $nrdolote ?>"/>
		
	</fieldset>		
	
</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
	<a href="#" class="botao" id="btConcluir" onclick="mostraLote(); return false;" >Concluir</a>
</div>

