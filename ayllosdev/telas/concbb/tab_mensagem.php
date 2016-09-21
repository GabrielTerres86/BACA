<? 
/*!
 * FONTE        : tab_mensagem.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 23/08/2011 
 * OBJETIVO     : Tabela que apresenta a consulta CONCBB
 * --------------
 * ALTERAÇÕES   : 05/03/2013 - Ajuste para o novo layout padrão (Gabriel).
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

<div id="tabMensagem">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th></th>
					<th></th>
				</tr>
			</thead>
			<tbody>
				<?
				$qtregist = count($mensagem);		
				foreach ( $mensagem as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrsequen'); ?></span>
							      <? echo getByTagName($r->tags,'nrsequen'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsmensag'); ?></span>
							      <? echo getByTagName($r->tags,'dsmensag'); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoes">
	<a href="#" class="botao" id="btSalvar" onClick="continuarMensagem(); return false;">Continuar</a>	
</div>
<br />		