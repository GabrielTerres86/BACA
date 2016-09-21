<?php
/*!
 * FONTE        : tab_cadcyb.php
 * CRIA��O      : Lucas R.
 * DATA CRIA��O : Agosto/2013 
 * OBJETIVO     : Tabela que apresenta os registros da tela CADCYB
 * --------------
 * ALTERA��ES   : 31/08/2015 - Ajustado a nomenclatura de VIP para CIN (Douglas - Melhoria 12)
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");	
	require_once("../../class/xmlfile.php");
	isPostMethod();		
?>

<div class="divRegistros">
	<table width="100%" id="tbCadcyb">
		<thead>
			<tr>
				<th>Origem</th>
				<th>Conta</th>
				<th>Contrato</th>
				<th>Judicial</th>
				<th>Extra Judicial</th>
				<th>CIN</th>
			</tr>
		</thead>
		<tbody id="regAssociado" name="regAssociado">
		</tbody>
	</table>
</div>