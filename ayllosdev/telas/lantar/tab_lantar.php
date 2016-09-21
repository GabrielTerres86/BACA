<? 
/*!
 * FONTE        : tab_lantar.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 13/03/2013 
 * OBJETIVO     : Tabela que apresenta a consulta LANTAR
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
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
?>

<div class="divRegistros">	
	<table width="100%">
		<thead>
			<tr>
				<th><? echo utf8ToHtml('PA'); ?></th>
				<th><? echo utf8ToHtml('Conta');  ?></th>
				<th><? echo utf8ToHtml('Matricula');  ?></th>
				<th><? echo utf8ToHtml('Tipo conta');  ?></th>
				<th><? echo utf8ToHtml('Titular');  ?></th>
				<th><? echo utf8ToHtml('Ch.') ?></th>
			</tr>
		</thead>
		<tbody id="regAssociado" name="regAssociado">
			
		</tbody>
	</table>
</div>	

 <div id="divBotoesTabLantar" style='margin-bottom :10px; text-align: center; display:none' >
	<a href="#" class="botao" id="btExcluir"  onClick="btnExcluir(); return false;">Excluir Selecionado</a>
</div>
