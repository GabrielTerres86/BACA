<?
/*!
 * FONTE        : form_tabela_consulta.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 08/03/2013
 * OBJETIVO     : Tabela para visualizacao dos dados
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>

var strHTML = "";
		
strHTML +='<div class="divDados">';
strHTML += '	<fieldset>';
		
strHTML += '<div class="divRegistros">';
	
strHTML += '		<table class="tituloRegistros" style="table-layout: fixed;">';
strHTML += '			<thead>';
strHTML += '				<tr><th>&nbsp;</th>';
strHTML += '                    <th><? echo utf8ToHtml('Dt. Solicit.'); ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Banco');  ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Conta Cheque');  ?></th>';
strHTML += '					<th><? echo utf8ToHtml('CPF / CNPJ');  ?></th>';
strHTML += '					<th><? echo utf8ToHtml('Situacao');  ?></th>';
strHTML += '					<th><? echo utf8ToHtml('CMC7');  ?></th>';
strHTML += '				</tr>';
strHTML += '			</thead>';
strHTML += '			<tbody>';
	
lstDadosICF = new Array();

var dados_count = <? echo $dados_count ?>;
<?php
		
for ($i = 0; $i < $dados_count; $i++){
	
	$dtinireq = getByTagName($dados[$i]->tags,"DTINIREQ");
	$dtfimreq = getByTagName($dados[$i]->tags,"DTFIMREQ");
	$cdbanori = str_pad(getByTagName($dados[$i]->tags,"CDBANORI"), 3, "0", STR_PAD_LEFT);
	$nrctaori = getByTagName($dados[$i]->tags,"NRCTAORI");
	$cdbanreq = str_pad(getByTagName($dados[$i]->tags,"CDBANREQ"), 3, "0", STR_PAD_LEFT);
	$cdagereq = getByTagName($dados[$i]->tags,"CDAGEREQ");
	$nrctareq = getByTagName($dados[$i]->tags,"NRCTAREQ");
	$nrcpfcgc = getByTagName($dados[$i]->tags,"NRCPFCGC");
	$nmprimtl = getByTagName($dados[$i]->tags,"NMPRIMTL");
	$dacaojud = getByTagName($dados[$i]->tags,"DACAOJUD");
	$cdcritic = getByTagName($dados[$i]->tags,"CDCRITIC");
	$cdtipcta = getByTagName($dados[$i]->tags,"CDTIPCTA");
	$dsstatus = getByTagName($dados[$i]->tags,"DSSTATUS");
	$dsdocmc7 = getByTagName($dados[$i]->tags,"DSDOCMC7");
		
	?>
	
	objRegistro = new Object();
	objRegistro.dtinireq = "<?php echo $dtinireq; ?>";
	objRegistro.dtfimreq = "<?php echo $dtfimreq; ?>";
	objRegistro.cdbanori = "<?php echo $cdbanori; ?>";
	objRegistro.nrctaori = "<?php echo $nrctaori; ?>";
	objRegistro.cdbanreq = "<?php echo $cdbanreq; ?>";
	objRegistro.cdagereq = "<?php echo $cdagereq; ?>";
	objRegistro.nrctareq = "<?php echo $nrctareq; ?>";
	objRegistro.nrcpfcgc = "<?php echo $nrcpfcgc; ?>";
	objRegistro.nmprimtl = "<?php echo $nmprimtl; ?>";
	objRegistro.dacaojud = "<?php echo $dacaojud; ?>";
	objRegistro.cdcritic = "<?php echo $cdcritic; ?>";
	objRegistro.cdtipcta = "<?php echo $cdtipcta; ?>";
	objRegistro.dsstatus = "<?php echo $dsstatus; ?>";
	objRegistro.dsdocmc7 = "<?php echo $dsdocmc7; ?>";
	lstDadosICF[<?php echo $i; ?>] = objRegistro;
	
	strHTML += '<tr id="trArquivosProcessados<?php echo $i; ?>" style="cursor: pointer;">';
	
	strHTML += '	<td width="15">';
	strHTML += '	<input type="checkbox" id="chkReenviarICF_<?php echo $i; ?>" />';
	strHTML += '	<input type="hidden" name="hddNrctareqICF_<?php echo $i; ?>" id="hddNrctareqICF_<?php echo $i; ?>" value="<?php echo $nrctareq; ?>">';
	strHTML += '	<input type="hidden" name="hddDacaojudICF_<?php echo $i; ?>" id="hddDacaojudICF_<?php echo $i; ?>" value="<?php echo $dacaojud; ?>">';
	strHTML += '	</td>';

	strHTML += '	<td width="70"><?php echo $dtinireq; ?></td>';
	strHTML += '	<td width="70"><?php echo $intipreq == 1 ? $cdbanreq : $cdbanori; ?></td>';
	strHTML += '	<td width="70"><?php echo $nrctareq; ?></td>';
	strHTML += '	<td width="70"><?php echo $nrcpfcgc; ?></td>';
	strHTML += '	<td width="70"><?php echo $dsstatus; ?></td>';
	strHTML += '	<td><?php echo $dsdocmc7; ?></td>';
	strHTML += '</tr>';
	
	<?php
}		
?>
		
strHTML += '			</tbody>';
strHTML += '		</table>';
strHTML += '</div>';
strHTML += '	</fieldset>';
strHTML += '</div>';

	
$("#divDadosConsulta").html(strHTML);
formataTabela("#divConsulta");
$("#divDadosConsulta").css("display","block");

hideMsgAguardo();
