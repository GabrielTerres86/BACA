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

	$arrayTitulares = array();
	for ( $i = 2; $i < 13; $i++){
		if ( count($registros[$i]) > 0 ){
			foreach( $registros[$i]->tags as $registro  ){
				$arrayTitulares[getByTagName($registro->tags,'idseqttl')][$i][] = getByTagName($registro->tags,'nmdcampo');
			}
		}
	
	}
	
	$cabec = $registros[0]->tags[0]->tags;	
?>

<html>
<head>
	<link href="../../../css/impressao.css" rel="stylesheet" type="text/css" />
	<style type="text/css">
		table, div { 
			font-family: monospace, "Courier New", Courier; 
			font-size:9pt;
		}	
	</style>	
</head>
<body>	
	<table>
		<tr><th colspan="4" style='text-align:left;'><? echo getByTagName($cabec,'nmextcop'); ?></th></tr>
		<tr><th style='width:110px;'>CONTA/DV:</th>
			<td style='width:62px;text-align:right;'><? echo getByTagName($cabec,'nrdconta'); ?></td>
			<td style='text-align:center;width:10px;'>-</td>
			<td><? echo getByTagName($cabec,'nmprimtl'); ?></td></tr>
		<tr><th colspan="4"  style='text-align:center;'>CRITICAS DE CADASTRAMENTO DE PESSOA FÍSICA</th></tr>	
	</table>
	
	<?for ( $i = 1; $i < 5; $i++ ){?>
	<table style='page-break-inside:auto;margin-top:15px'>
		<?if ( count($arrayTitulares[$i]) > 0 ){?>
			<tr><th colspan="2" style='text-align:left;padding-left:15px;'>===> FALTA PREENCHER AS SEGUINTES INFORMAÇÕES DO  <?echo $i;?>º TITULAR</th></tr>
			<?if ( count($arrayTitulares[$i][2]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>IDENTIFICAÇÃO</td></tr>
				<?foreach( $arrayTitulares[$i][2] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
			
			<?if ( count($arrayTitulares[$i][3]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>FILIAÇÃO</td></tr>
				<?foreach( $arrayTitulares[$i][3] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
			
			<?if ( count($arrayTitulares[$i][4]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>ENDEREÇO</td></tr>
				<?foreach( $arrayTitulares[$i][4] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
			
			<?if ( count($arrayTitulares[$i][5]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>COMERCIAL</td></tr>
				<?foreach( $arrayTitulares[$i][5] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
			
			<?if ( count($arrayTitulares[$i][6]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>TELEFONE</td></tr>
				<?foreach( $arrayTitulares[$i][6] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
			
			<?if ( count($arrayTitulares[$i][7]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>CÔNJUGE</td></tr>
				<?foreach( $arrayTitulares[$i][7] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
			
			<?if ( count($arrayTitulares[$i][8]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>CONTATO</td></tr>
				<?foreach( $arrayTitulares[$i][8] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
			
			<?if ( count($arrayTitulares[$i][9]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>RESPONSAVEL LEGAL</td></tr>
				<?foreach( $arrayTitulares[$i][9] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
			
			<?if ( count($arrayTitulares[$i][10]) > 0 ){?>
				<tr><th style='width:70px;'>ITEM:</th>
					<td>CONTA CORRENTE</td></tr>
				<?foreach( $arrayTitulares[$i][10] as $item ){?>	
				<tr><td></td>
					<td> - <?echo $item; ?></td></tr>
				<?}?>	
			<?}?>
		<?}?>
	</table>
	<?}?>
	<div class='bloco'>Impresso em <? echo getByTagName($cabec,'dtmvtolt'); ?> pelo Operador: <? echo getByTagName($cabec,'nmoperad'); ?></div>
</body>
</html>
