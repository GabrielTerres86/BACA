<?php
/*!
 * FONTE        : lista_contas.php
 * CRIAÇÃO      : Gabriel Ramirez (RKAM)
 * DATA CRIAÇÃO : 30/07/2015
 * OBJETIVO     : Formulario para selecionar conta a duplicar
 * --------------
 * ALTERAÇÕES   : 
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
	
	$XMLContas = $_POST["XMLContas"];
	
	$registros = explode("|",$XMLContas);
?>

<form id="frmContas" name="frmContas" class="formulario" onsubmit="return false;">

	<fieldset>
		<legend><? echo utf8ToHtml('Informe a C/C a ser duplicada') ?></legend>
		
		<div class="divRegistros">
		<table>
			<thead>
				<tr><th>Conta/dv</th>
					<th>Data de admiss&atilde;o</th>
				</tr>			
			</thead>
			<tbody>
				<? foreach( $registros as $registro ) { 
					$registro = explode(";",$registro);
					$nrdconta = $registro[0];
					$dtadmiss = $registro[1];
				?>
					<tr onclick="selecionaConta('<? echo $nrdconta; ?>');">
						<td><? echo $nrdconta; ?></td>
						<td><? echo $dtadmiss; ?></td>

					</tr>				
				<? } ?>			
			</tbody>
		</table>
	</div> 
		
	</fieldset>	
</form>

<div id="divBotoes2">
	<a href="#" class="botao" id="btnVoltar" onclick="fechaRotina($('#divRotina')); return false;">Voltar</a>
</div>