<?php
/*!
 * FONTE        : form_contacontrato.php
 * CRIAÇÃO      : Marcel Kohls / AMCom
 * DATA CRIAÇÃO : 20/03/2018
 * OBJETIVO     : Formulario de filtros de ativos problematicos
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
	// session_start();
	// require_once('../../includes/config.php');
	// require_once('../../includes/funcoes.php');
	// require_once('../../includes/controla_secao.php');
	// require_once('../../class/xmlfile.php');
	// require_once("../../includes/carrega_permissoes.php");


	$dataHoje = $glbvars['dtmvtolt'];
?>

<form id="frmFiltro" name="frmFiltro" class="formulario">
	<fieldset>
		<legend> <? echo utf8ToHtml('Filtros');  ?> </legend>
    <label for="nrdconta">Conta:</label>
    <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>" />
    <a id="btnLupaAssociado"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

    <label for="nrctrato">Contrato:</label>
    <input type="text" id="nrctrato" name="nrctrato" value="<?php echo $nrctrato ?>"/>

		<label for="flmotivo">Motivo:</label>
		<select id="flmotivo" name="flmotivo">
			<?php
				$tipoLista = "T";	// indica que deve m ser listados Todos os motivos
				include("lista_motivos.php");
			?>
		</select>

		<label for="fldtinic">Data Inicial:</label>
		<input type="text" id="fldtinic" name="fldtinic" value="<?php echo $dataHoje; ?>" />

		<label for="fldtfina">Data Final:</label>
		<input type="text" id="fldtfina" name="fldtfina" value="<?php echo $dataHoje; ?>" />
	</fieldset>
  <div id="divBotoesFiltro" style="text-align:center; padding-bottom:10px; clear: both; float: none;">
    <a href="#" class="botao" style="float:none;" id="btVoltar" onclick="voltarFiltro();">Voltar</a>
    <a href="#" class="botao" style="float:none;" onclick="continuarFiltro();" >Prosseguir</a>
  </div>
</form>
