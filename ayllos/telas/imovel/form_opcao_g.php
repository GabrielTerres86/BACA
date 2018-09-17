<?php 
/*!
 * FONTE        : form_opcao_g.php
 * CRIAÇÃO      : Renato Darosci - Supero
 * DATA CRIAÇÃO : 22/06/2016 
 * OBJETIVO     : Formulario que apresenta a opcao G da tela de IMOVEL, permitindo a emissão 
 *				  dos arquivos a serem enviados ao CETIP
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

<form id="frmOpcao" class="formulario" >

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<fieldset>
		<legend> <?php echo utf8ToHtml('Arquivo'); ?> </legend>

		<label for="cdcooper">Cooperativa:</label>
		<select id="cdcooper" name="cdcooper"></select>

		<label for="intiparq">Tipo:</label>
		<select id="intiparq" name="intiparq">
			<option value="T">Todas</option>
			<option value="I"><?php echo utf8ToHtml('Inclusão'); ?></option>
			<option value="B">Baixa</option>
		</select>

	</fieldset>	

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnGerarArquivo(); return false;" >Prosseguir</a>
</div>


