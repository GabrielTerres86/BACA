<? 
/*!
 * FONTE        : form_opcao_i.php
 * CRIA��O      : Helinton Steffens - (Supero)
 * DATA CRIA��O : 13/03/2018 
 * OBJETIVO     : Formulario para conciliar uma ted.
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');
isPostMethod();

?>

<!--
<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_extrato_consolidado_pdf.php" method="post" id="frmExportarPDF" name="frmExportarPDF">		
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>
-->

<form id="frmOpcao" class="formulario" onSubmit="return false;">
	<fieldset>
		<legend>Informe o per&iacute;odo</legend>
		<table>
			<tr>		
				<td>
					<label for="dtinimvt">Data inicial:</label>
					<input type="text" id="dtinimvt" name="dtinimvt" value="<? echo $dtinimvt ?>" />
				</td>
				<td>
					<label for="dtfimmvt">Data final:</label>
					<input type="text" id="dtfimmvt" name="dtfimmvt" value="<? echo $dtfimmvt ?>" />
				</td>
			</tr>
		</table>
	</fieldset>
</form>

<form action="<?php echo $UrlSite;?>telas/manprt/imprimir_extrato_consolidado_pdf.php" method="post" id="frmExportarPDF" name="frmExportarPDF">		
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" name="dtinimvt" id="dtinimvt" value="<?php echo $dtinimvt; ?>">
	<input type="hidden" name="dtfimmvt" id="dtfimmvt" value="<?php echo $dtfimmvt; ?>">
</form>

<div id="divBotoes" style='margin-bottom :10px'>
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar" onclick="exportarConsultaPDF(); return false;" >Prosseguir</a>
</div> 

<!--<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
</div>-->
