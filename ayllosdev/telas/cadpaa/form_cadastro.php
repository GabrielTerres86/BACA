<?php 
/*!
 * FONTE        : form_cadastro.php
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
		<legend> <?php echo utf8ToHtml('PA Administrativo'); ?> </legend>

		<label for="cdcooper">Cooperativa:</label>
		<select id="cdcooper" name="cdcooper"></select>
		
		<label for="cdpa_admin"><?php echo utf8ToHtml('Código PA:'); ?></label>
		<input type="text" id="cdpa_admin" name="cdpa_admin" maxlength="10" />
		
		<label for="dspa_admin"><?php echo utf8ToHtml('Descrição:'); ?></label>
		<input type="text" id="dspa_admin" name="dspa_admin" maxlength="100" />
		
		<label for="tprateio">Rateio:</label>
		<select id="tprateio" name="tprateio"></select>
		
		<label for="flgativo"><? echo utf8ToHtml('Ativo:') ?></label>	
		<input name="flgativo" type="checkbox"  id="flgativo" style="border:none;"/>
		
		<br style="clear:both;">
		<br style="clear:both;">
		
		<label for="ds_dtinclus"><? echo utf8ToHtml('Inclusão:') ?></label>	
		<input type="text" id="ds_dtinclus" name="ds_dtinclus" />
		<label for="ds_dsinclus"></label>	
		<input type="text" id="ds_dsinclus" name="ds_dsinclus" />
		
		<label for="ds_dtaltera"><? echo utf8ToHtml('Alteração:') ?></label>	
		<input type="text" id="ds_dtaltera" name="ds_dtaltera" />
		<label for="ds_dsaltera"></label>	
		<input type="text" id="ds_dsaltera" name="ds_dsaltera" />
		
		<label for="ds_dtinativ"><? echo utf8ToHtml('Inativação:') ?></label>	
		<input type="text" id="ds_dtinativ" name="ds_dtinativ" />
		<label for="ds_dsinativ"></label>	
		<input type="text" id="ds_dsinativ" name="ds_dsinativ" />
	</fieldset>	
	<div id="divReplica" > </div>
</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnGerarArquivo(); return false;" >Prosseguir</a>
</div>


