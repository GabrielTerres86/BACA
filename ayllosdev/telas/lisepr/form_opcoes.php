<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Adriano 					
 * DATA CRIAÇÃO : 25/02/2015
 * OBJETIVO     : Formulário com as opções de filtro para pesquisa dos esmpréstimos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 ?>

 <?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<form id="frmOpcoes" name="frmOpcoes" class="formulario" style="display:none;">

	<fieldset id="fsetOpcoes" name="fsetOpcoes" style="padding:0px; margin:0x; padding-bottom:10px;">
	
		<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
		<input id="cdagenci" name="cdagenci" type="text"/>
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
		<label for="cdlcremp">Linha de Cr&#233;dito:</label>
		<input type="text" id="cdlcremp" name="cdlcremp" value="<? echo $cdlcremp == 0 ? '' : $cdlcremp ?>" alt="Informe a linha de credito." />
		
		<label for="cddotipo"><? echo utf8ToHtml('Tipo') ?></label>
		<select id="cddotipo" name="cddotipo">
			<option value="X" selected> Todas </option>
			<option value="E"> Empr&#233;stimos </option>
			<option value="T"> T&#237;tulos </option>
			<option value="C"> Cheques </option>
		</select>
		
		<label for="dtinicio"><? echo utf8ToHtml('Periodo:') ?></label>
		<input name="dtinicio" id="dtinicio" type="text" value="<? echo $dtinicio ?>" autocomplete="off" />
		
		<label for="dttermin"><? echo utf8ToHtml('a') ?></label>
		<input name="dttermin" id="dttermin" type="text" value="<? echo $dttermin ?>" autocomplete="off" />
		
		<label for="tipsaida"><? echo utf8ToHtml('Saida') ?></label>
		<select id="tipsaida" name="tipsaida">
			<option value="1" selected>Arquivo</option>			
			<option value="2" >Impressão</option>
		</select>
		
	</fieldset>
		
</form>

<form name="frmImprimir" id="frmImprimir">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<input name="cdagenci" id="cdagenci" type="hidden" value="" />
	<input name="cddopcao" id="cddopcao" type="hidden" value="" />
	<input name="cdlcremp" id="cdlcremp" type="hidden" value="" />
	<input name="dtinicio" id="dtinicio" type="hidden" value="" />
	<input name="dttermin" id="dttermin" type="hidden" value="" />
	<input name="cddotipo" id="cddotipo" type="hidden" value="" />

</form>