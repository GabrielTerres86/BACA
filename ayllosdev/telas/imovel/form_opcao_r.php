<?php 
/*!
 * FONTE        : form_opcao_r.php
 * CRIAÇÃO      : Renato Darosci - Supero
 * DATA CRIAÇÃO : 22/06/2016 
 * OBJETIVO     : Formulario que apresenta a opcao R da tela de IMOVEL, permitindo o processamento 
 *				  dos arquivos de retorno que foram recebidos do Cetip
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

<form id="frmRetorno" class="formulario" >
	<fieldset>
		<legend> <?php echo utf8ToHtml('Retorno'); ?> </legend>
		<div id="divBotoes" style="padding-bottom:15px">
			<a href="#" class="botao" onclick="btnRetornoArquivo(); return false;" >  Processar Arquivos de Retorno  </a>
		</div>
	</fieldset>	

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
</div>


