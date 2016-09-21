<?
/*!
 * FONTE        : imp_critica_pf_html.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 17/05/2010 
 * OBJETIVO     : Responsável por buscar as informações que serão apresentadas no PDF de critica da tela de Conta Corrente
 */	 
?>
<?
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	$registros = $GLOBALS['registros']; 	
	
	$arrayRotinas = array();
	for ( $i = 2; $i < 13; $i++){
		if ( count($registros[$i]) != 0 ){
			foreach( $registros[$i]->tags as $registro  ){
				$arrayRotinas[$i][] = getByTagName($registro->tags,'nmdcampo');
			}
		}
	
	}
	
	$cabec = $registros[0]->tags[0]->tags;	
?>
<html>
<head>
	<link href="../../../css/impressao.css" rel="stylesheet" type="text/css" />
	<style type="text/css">
		table, div, h4 { 
			font-family: monospace, "Courier New", Courier; 
			font-size:9pt;
		}	
	</style>
</head>
<body>	
	<table style='margin-bottom:15px;'>
		<tr><th colspan="4" style='text-align:left;'><? echo getByTagName($cabec,'nmextcop'); ?></th></tr>
		<tr><th style='width:110px;'>CONTA/DV:</th>
			<td style='width:62px;text-align:right;'><? echo getByTagName($cabec,'nrdconta'); ?></td>
			<td style='text-align:center;width:10px;'>-</td>
			<td><? echo getByTagName($cabec,'nmprimtl'); ?></td></tr>
		<tr><th colspan="4" style='text-align:center;'>CRITICAS DE CADASTRAMENTO DE PESSOA JURÍDICA</th></tr>	
	</table>
	
	<?if ( count($arrayRotinas[2]) > 0 ){?>
		<h4 style='margin-top:15px;'>ITEM: IDENTIFICAÇÃO</h4>		
		<table style="page-break-inside:auto;">
			<tr><td style='padding-left:35px;' colspan="2">Falta preencher as seguintes informações:</td></tr>
			<?foreach( $arrayRotinas[2] as $item ){?>	
				<tr><td style='width:120px'> </td>
					<td> - <?echo $item; ?></td></tr>
			<?}?>
		</table>
	<?}?>
	
	<?if ( count($arrayRotinas[4]) > 0 ){?>
		<h4 style='margin-top:15px;'>ITEM: ENDEREÇO</h4>		
		<table style="page-break-inside:auto;">
			<tr><td style='padding-left:35px;' colspan="2">Falta preencher as seguintes informações:</td></tr>
			<?foreach( $arrayRotinas[4] as $item ){?>	
				<tr><td style='width:120px'> </td>
					<td> - <?echo $item; ?></td></tr>
			<?}?>
		</table>
	<?}?>
	
	<?if ( count($arrayRotinas[10]) > 0 ){?>
		<h4 style='margin-top:15px;'>ITEM: CONTA CORRENTE</h4>		
		<table style="page-break-inside:auto;">
			<tr><td style='padding-left:35px;' colspan="2">Falta preencher as seguintes informações:</td></tr>
			<?foreach( $arrayRotinas[10] as $item ){?>	
				<tr><td style='width:120px'> </td>
					<td> - <?echo $item; ?></td></tr>
			<?}?>
		</table>
	<?}?>
	
	<?if ( count($arrayRotinas[11]) > 0 ){?>
		<h4 style='margin-top:15px;'>ITEM: REGISTRO</h4>		
		<table style="page-break-inside:auto;">
			<tr><td style='padding-left:35px;' colspan="2">Falta preencher as seguintes informações:</td></tr>
			<?foreach( $arrayRotinas[11] as $item ){?>	
				<tr><td style='width:120px'> </td>
					<td> - <?echo $item; ?></td></tr>
			<?}?>
		</table>
	<?}?>
	
	<?if ( count($arrayRotinas[12]) > 0 ){?>
		<h4 style='margin-top:15px;'>ITEM: REPRESENTANTES/PROCURADORES</h4>		
		<table style="page-break-inside:auto;">
			<tr><td style='padding-left:35px;' colspan="2">Falta preencher as seguintes informações:</td></tr>
			<?foreach( $arrayRotinas[12] as $item ){?>	
				<tr><td style='width:120px'> </td>
					<td> - <?echo $item; ?></td></tr>
			<?}?>
		</table>
	<?}?>
	<br style='clear:both;' />
	<div class='bloco' style="padding-top:20px;">Impresso em <? echo getByTagName($cabec,'dtmvtolt'); ?> pelo Operador: <? echo getByTagName($cabec,'nmoperad'); ?></div>

</body>
</html>