<?php 
/*!
 * FONTE        : form_opcao_i.php
 * CRIAÇÃO      : Renato Darosci - Supero
 * DATA CRIAÇÃO : 21/06/2016 
 * OBJETIVO     : Formulario que apresenta a opcao I da tela de IMOVEL, permitindo a emissão de relatórios
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
	<input type="hidden" name="cddopcao" id="cddopcao">

	<fieldset>
		<legend> <?php echo utf8ToHtml('Relatórios'); ?> </legend>

		<label for="inrelato"><?php echo utf8ToHtml('Relatório'); ?>:</label>
		<select id="inrelato" name="inrelato">
			<option value="1">1 - <?php echo utf8ToHtml('Relatórios'); ?> de acompanhamento dos arquivos enviados para a Cetip</option>
			<option value="2">2 - <?php echo utf8ToHtml('Relatórios'); ?> dos registros inclusos e baixados manualmente</option>
		</select>
		
		<label for="cdcooper">Cooperativa:</label>
		<select id="cdcooper" name="cdcooper"></select>

		<label for="intiprel">Tipo:</label>
		<select id="intiprel" name="intiprel">
			<option value="T">Todas</option>
			<option value="I"><?php echo utf8ToHtml('Inclusão'); ?></option>
			<option value="A"><?php echo utf8ToHtml('Alteração'); ?></option>
			<option value="B">Baixa</option>
			<option value="C"><?php echo utf8ToHtml('Crítica'); ?></option>
		</select>

		<label for="dtrefere"><?php echo utf8ToHtml('Referência'); ?>:</label>
		<input type="text" id="dtrefere" name="dtrefere" />

		<label for="cddolote">Lote:</label>
		<input type="text" id="cddolote" name="cddolote" />
		
	</fieldset>	

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnRelatorio(); return false;" >Prosseguir</a>
</div>


