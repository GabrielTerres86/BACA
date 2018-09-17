<? 
/*!
 * FONTE        : tab_cheques.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 05/07/2011 
 * OBJETIVO     : Tabela que apresenta as cheques em custodia/desconto
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
	$cheque = (isset($_POST['cheque'])) ? unserialize($_POST['cheque']) : '';
	
?>

<div id="divCheque">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Favorecido'); ?></th>
					<th><? echo utf8ToHtml('Descrição'); ?></th>
					<th><? echo utf8ToHtml('Cheque');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				$total = count($cheque);
				
				for ( $i = 0; $i < $total; $i++ ) { 
				?>
					<tr>
						<td><span><? echo $cheque[$i]['nrdconta'] ?></span>
							      <? echo formataContaDV($cheque[$i]['nrdconta']) ?>
								  <input type="hidden" id="tpcheque" name="tpcheque" value="<? echo $cheque[$i]['tpcheque'] ?>" />								  
								  <input type="hidden" id="dtlibera" name="dtlibera" value="<? echo $cheque[$i]['dtlibera'] ?>" />								  
								  <input type="hidden" id="cdpesqui" name="cdpesqui" value="<? echo $cheque[$i]['cdpesqui'] ?>" />								  
								  
						</td>
						<td><span><? echo $cheque[$i]['nmprimtl'] ?></span>
							      <? echo $cheque[$i]['nmprimtl'] ?>
						</td>
						<td><span><? echo $cheque[$i]['nrcheque'] ?></span>
							      <? echo mascara($cheque[$i]['nrcheque'],'###.###') ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divChequeLinha1">
<ul class="complemento">
<li><? echo utf8ToHtml('Cheque em:'); ?></li>
<li id="tpchequeLi"><? echo $cheque[0]['tpcheque']?></li>
<li><? echo utf8ToHtml('Liberação em:'); ?></li>
<li id="dtliberaLi"><? echo $cheque[0]['dtlibera']?></li>
</ul>
</div>

<div id="divChequeLinha2">
<ul class="complemento">
<li><? echo utf8ToHtml('Digitação em:'); ?></li>
<li id="cdpesquiLi"><? echo $cheque[0]['cdpesqui']?></li>
</ul>
</div>

<div id="divBotoes">
	<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="btnContinuar(); return false;" />
</div>