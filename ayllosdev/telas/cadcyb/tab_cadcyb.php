<?php
/*!
 * FONTE        : tab_cadcyb.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013 
 * OBJETIVO     : Tabela que apresenta os registros da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 31/08/2015 - Ajustado a nomenclatura de VIP para CIN (Douglas - Melhoria 12)
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * 				  04/06/2018 - Projeto 403 - Inclusão de tratativas para a inclusão de títulos vencidos na Cyber (Lucas - GFT) 
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
				<th id="thnrctremp">Contrato</th>
				<th id="thnrborder">Borderô</th>
				<th id="thnrtitulo">Título</th>
				<th>Judicial</th>
				<th>Extra Judicial</th>
				<th>CIN</th>
			</tr>
		</thead>
		<tbody id="regAssociado" name="regAssociado">
		</tbody>
	</table>
</div>