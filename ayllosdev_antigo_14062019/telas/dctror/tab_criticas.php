<? 
/*!
 * FONTE        : tab_criticas.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 08/07/2011 
 * OBJETIVO     : Tabela que apresenta criticas
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

	
	// Guardo os parâmetos do POST em variáveis	
	$criticas = (isset($_POST['criticas'])) ? unserialize($_POST['criticas']) : '';

	
?>

<div id="divCriticas">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Banco'); ?></th>
					<th><? echo utf8ToHtml('Agência'); ?></th>
					<th><? echo utf8ToHtml('Conta Cheque');  ?></th>
					<th><? echo utf8ToHtml('Cheque');  ?></th>
					<th><? echo utf8ToHtml('Critica');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				$total = count($criticas);
				
				for ( $i = 0; $i < $total; $i++ ) { 
				?>
					<tr>
						<td><span><? echo $criticas[$i]['cdbanchq'] ?></span>
							      <? echo $criticas[$i]['cdbanchq'] ?>
						</td>
						<td><span><? echo $criticas[$i]['cdagechq'] ?></span>
							      <? echo $criticas[$i]['cdagechq'] ?>
						</td>
						<td><span><? echo $criticas[$i]['nrctachq'] ?></span>
							      <? echo mascara($criticas[$i]['nrctachq'],'####.###.#') ?>
						</td>
						<td><span><? echo $criticas[$i]['nrcheque'] ?></span>
							      <? echo mascara($criticas[$i]['nrcheque'],'###.###.#') ?>
						</td>
						<td><span><? echo $criticas[$i]['dscritic'] ?></span>
							      <? echo $criticas[$i]['dscritic'] ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoes">
	<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/fechar.gif" onClick="btnCritica(); return false;" />
</div>