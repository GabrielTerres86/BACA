<? 
/*!
 * FONTE        : tab_cadcyb.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013 
 * OBJETIVO     : Tabela que apresenta os registros da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 31/08/2015 - Ajustado a nomenclatura de VIP para CIN (Douglas - Melhoria 12)
 * --------------
 */
 
 	session_start();
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
				<th><? echo utf8ToHtml("Origem"); ?></th>
				<th><? echo utf8ToHtml("Conta"); ?></th>
				<th><? echo utf8ToHtml("Contrato"); ?></th>
				<th><? echo utf8ToHtml("Judicial"); ?></th>
				<th><? echo utf8ToHtml("Extra Judicial"); ?></th>
				<th><? echo utf8ToHtml("CIN"); ?></th>
			</tr>
		</thead>
		<tbody id="regAssociado" name="regAssociado">
		</tbody>
	</table>
</div>