<? 
/*!
 * FONTE        : formulario_lotprc.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 07/05/2013 
 * OBJETIVO     : Controla as opcoes, sendo possivel determinados tipos de formulario conforme opcao.
 * --------------
 * ALTERAÇÕES   : 14/10/2013 - Ajustes em labels dos campos. 
 *							   Adicionado opcao "W". (Jorge).
 *
 *				  29/10/2013 - Adicionado opcao "R" e ajustes de rotina. (Jorge)
 *                30/07/2018 - SCTASK0021664 Inclusão do campo vlperfin (percentual financiado) (Carlos)
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
	
	$cddopcao = isset($_POST["cddopcao"]) ? $_POST["cddopcao"] : "";
	
	switch ($cddopcao){
		case "N": $titulo_legend = "Abrir Novo Lote"; 							break;
		case "I": $titulo_legend = "Incluir Conta no Lote"; 					break;
		case "C": $titulo_legend = "Consultar Conta no Lote"; 					break;
		case "A": $titulo_legend = "Alterar Conta no Lote"; 					break;
		case "E": $titulo_legend = "Excluir Conta no Lote"; 					break;
		case "W": $titulo_legend = "Incluir informações no Lote"; 				break;
		case "F": $titulo_legend = "Fechar Lote"; 								break;
		case "L": $titulo_legend = "Reabrir Lote"; 								break;
		case "Z": $titulo_legend = "Finalizar Lote"; 							break;
		case "G": $titulo_legend = "Gerar arquivo para encaminhamento ao BRDE"; break;
		case "T": $titulo_legend = "Gerar arquivo final ao BRDE"; 				break;
		case "R": $titulo_legend = "Relatório de Lotes"; 						break;
		default : $titulo_legend = "Manutenção de Lote"; 						break;
	}
	
?>



<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<fieldset>
		<legend> <? echo utf8ToHtml($titulo_legend);  ?> </legend>	
		
		<label for="nrdolote">Lote:</label>
		<input type="text" id="nrdolote" name="nrdolote" class="campo" />
		
		<label for="nrdconta">Conta/DV:</label>
		<input type="text" id="nrdconta" name="nrdconta" class="campo" />
		
	</fieldset>		
	
</form>

<form id="frmContaLote" class="formulario" onSubmit="return false;" style="display:none;">

	<fieldset>
		<legend> <? echo utf8ToHtml($titulo_legend);  ?> </legend>	
		
		<label for="vlprocap">Valor do Procapcred:</label>
		<input type="text" id="vlprocap" name="vlprocap" class="campo" />
		<label for="dtvencnd">Data vencimento CND INSS:</label>
		<input type="text" id="dtvencnd" name="dtvencnd" class="campo" />
		<br />
		<label for="cdmunben">C&oacute;digo BNDES do munic&iacute;pio:</label>
		<input type="text" id="cdmunben" name="cdmunben" class="campo" />
		<label for="cdgenben">G&ecirc;nero do cooperado:</label>
		<input type="text" id="cdgenben" name="cdgenben" class="campo" />
		<br />
		<label for="cdporben">Porte do cooperado:</label>
		<input type="text" id="cdporben" name="cdporben" class="campo" />
		<label for="cdsetben">Setor de atividade (CNAE):</label>
		<input type="text" id="cdsetben" name="cdsetben" class="campo" />
		<br />
		<label for="dtcndfed">Data de vencimento CND FEDERAL:</label>
		<input type="text" id="dtcndfed" name="dtcndfed" class="campo" />
		<label for="dtcndfgt">Data de vencimento CND FGTS:</label>
		<input type="text" id="dtcndfgt" name="dtcndfgt" class="campo" />
		<br />
		<label for="dtcndest">Data de vencimento CND ESTADUAL:</label>
		<input type="text" id="dtcndest" name="dtcndest" class="campo" />
		<br />
	</fieldset>		
	
</form>

<form id="frmCadLote" class="formulario" onSubmit="return false;" style="display:none;">

	<fieldset>
		<legend> <? echo utf8ToHtml($titulo_legend);  ?> </legend>	
		
		<label for="dtcontrt">Data de contrata&ccedil;&atilde;o:</label>
		<input type="text" id="dtcontrt" name="dtcontrt" class="campo" /> 
		<br />
		<label for="dtpricar">Data da primeira car&ecirc;ncia:</label>
		<input type="text" id="dtpricar" name="dtpricar" class="campo" />
		<label for="dtfincar">Data da &uacute;ltima car&ecirc;ncia:</label>
		<input type="text" id="dtfincar" name="dtfincar" class="campo" />
		<br />
		<label for="dtpriamo">Data da primeira amortiza&ccedil;&atilde;o:</label>
		<input type="text" id="dtpriamo" name="dtpriamo" class="campo" />
		<label for="dtultamo">Data da &uacute;ltima amortiza&ccedil;&atilde;o:</label>
		<input type="text" id="dtultamo" name="dtultamo" class="campo" />
		<br />
		<label for="cdmunbce">C&oacute;d. BACEN do munic&iacute;pio da opera&ccedil;&atilde;o:</label>
		<input type="text" id="cdmunbce" name="cdmunbce" class="campo" />
		<label for="cdsetpro">C&oacute;d. CNAE do setor de atividade do proj:</label>
		<input type="text" id="cdsetpro" name="cdsetpro" class="campo" />
		<br />
        
		<label for="vlperfin">Percentual financiado:</label>
		<input type="text" id="vlperfin" name="vlperfin" class="campo" />
		<br />
        
	</fieldset>		
	
</form>

<form name="frmImprimir" id="frmImprimir" style="display:none">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input name="nmarquiv" id="nmarquiv" type="hidden" value="" />
</form>	

<div id="divAvalista"></div>
