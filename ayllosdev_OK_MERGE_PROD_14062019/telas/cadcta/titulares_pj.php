<?php
/*!
 * FONTE        : titulares_pj.php
 * CRIAÇÃO      : Andrey Formigari (Mouts)
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Listar titulares na tela CADCTA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
session_start();	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");
require_once("../../class/xmlfile.php");	
isPostMethod();

$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
$idseqttl = $_POST["idseqttl"] == "" ? 1 : $_POST["idseqttl"];
$nrcpfcgc = $_POST["nrcpfcgc"] == "" ? 0 : $_POST["nrcpfcgc"];
$nmextttl = $_POST["nmextttl"] == "" ? 0 : $_POST["nmextttl"];
// Pessoa juridica não possui titulares, por isso apenas exibi dados carregados do cabecalho


?>

<form id="frmConsultaDados" class="formulario" name="frmConsultaDados">
	<fieldset>
		<legend>Titulares</legend>
		<div class="divRegistros divRegistrosC">
			<table>
				<thead>
				<tr>
					<th>Nome</th>
					<th>C.N.P.J.</th>
				</tr>			
				</thead>
				<tbody> 					
					<tr>
						<td style="overflow-x: hidden; white-space: nowrap;"><?php echo $nmextttl; ?></td>
						<td><?php echo formataNumericos('99.999.999/9999-90', $nrcpfcgc,'.-/'); ?></td>
					</tr>					
				</tbody>
			</table>
		</div>
	</fieldset>
</form>