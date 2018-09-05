<?php
/*!
 * FONTE        : form_inclui_segmento_cdc.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 26/05/2018
 * OBJETIVO     : Formulário para inclusão de Segmentos de Convenio CDC
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	 
 
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
 
$idcooperado_cdc = (isset($_POST['idcooperado_cdc'])) ? $_POST['idcooperado_cdc'] : 0  ;
?>
<form name="frmIncluiSegCdc" id="frmIncluiSegCdc" class="formulario">
	<fieldset style="padding: 5px; height: 50px;">
		<legend style="margin-top: 10px; padding: 2px 10px 2px 10px">Inclus&atilde;o de Subsegmento</legend>
		<input type="hidden" id="idcooperado_cdc" name="idcooperado_cdc" value="<?php echo $idcooperado_cdc; ?>" />	
		<label for="cdsubsegmento">Subsegmento:</label>
		<input type="text" id="cdsubsegmento" name="cdsubsegmento" value=""/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" onclick="controlaPesquisasSegmentos();"></a>		
		<input type="text" id="dssubsegmento" name="dssubsegmento" value="" readonly />
	</fieldset>	
</form>
<div id="divBotoes">	
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="acessaOpcaoAba('S',1); return false;" />
	<input type="image" id="btConcluir" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="manterSubsegmento('I'); return false;" />
</div>
<script>
	formataInclusaoSegmento();
</script>