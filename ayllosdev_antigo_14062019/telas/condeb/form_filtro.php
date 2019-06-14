<?php
/*!
 * FONTE        : form_filtro.php
 * CRIAÇÃO      : Marcel Kohls / AMCom
 * DATA CRIAÇÃO : 20/03/2018
 * OBJETIVO     : Formulario de filtros de debitos pendentes
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
	$dataHoje = $glbvars['dtmvtolt'];
?>
<script type="text/javascript">
	dataHoje = "<?= $dataHoje ?>";
</script>

<form id="frmFiltro" name="frmFiltro" class="formulario">
	<fieldset>
		<legend> <? echo utf8ToHtml('Filtros');  ?> </legend>
    <label for="cdsituac"><? echo utf8ToHtml('Situação:') ?></label>
  	<select id="cdsituac" name="cdsituac" onchange="defineCamposSituacao()">
  		<option value="1">1 - Pendente</option>
  		<option value="2">2 - Efetivado</option>
  	</select>
    <label for="flprogra" class="pendentes">Programa:</label>
		<select id="flprogra" name="flprogra" class="pendentes">
			<?php
				include("lista_programas.php");
			?>
		</select>
    <label for="nrdconta">Conta:</label>
    <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>" />
    <a id="btnLupaAssociado"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

    <label for="cdagenci">PA:</label>
    <input type="text" id="cdagenci" name="cdagenci" value="1"/>
		<a id="btnLupaAgencia"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="dtmvtolt">Data:</label>
		<input type="text" id="dtmvtolt" name="dtmvtolt" value="<?= $dataHoje ?>" />

	</fieldset>
  <div id="divBotoesFiltro" style="text-align:center; padding-bottom:10px; clear: both; float: none;">
    <a href="#" class="botao" style="float:none;" onclick="listarDebitos();" >Prosseguir</a>
  </div>
</form>
