<?php
/*!
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Gabriel Capoia - (DB1)
 * DATA CRIAÇÃO : 21/01/2013 
 * OBJETIVO     : Tabela que apresenta os contratos
 * --------------
 * ALTERAÇÕES   : 23/07/2015 - Incluído a coluna TpContrato, assim como no caracter - Jéssica (DB1)
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');	
	isPostMethod();
	
?>

<div id="divTabela">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th>Contrato</th>					
					<th>Pesquisa</th>					
					<th>Conta/dv</th>
					<th>Nome</th>
					<th>Tipo</th>
					<th>Divida</th>					
				</tr>
			</thead>
			<tbody>
										
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrctremp') ?></span>
							<? echo mascara(getByTagName($r->tags,'nrctremp'),'#.###.###') ?></td>
						
						<td><? echo getByTagName($r->tags,'cdpesqui') ?></td>
						
						<td><span><? echo getByTagName($r->tags,'nrdconta') ?></span>
							<? echo mascara(getByTagName($r->tags,'nrdconta'),'####.###.#') ?></td>
													
						<td><? echo substr(getByTagName($r->tags,'nmprimtl'),0,28) ?></td>
						
						<td><? echo getByTagName($r->tags,'tpdcontr') ?></td>
						
						<?$vldivida = getByTagName($r->tags,'vldivida')?>
																		
						<?if ($vldivida == "Prejuizo") { ?>
																				
							<td><? echo getByTagName($r->tags,'vldivida') ?></td>
					
						<?}else {?>
													
							<td><span><? echo number_format(str_replace(",","",getByTagName($r->tags,"vldivida")),4,",","."); ?></span>
									  <? echo number_format(str_replace(",","",getByTagName($r->tags,"vldivida")),2,",","."); ?></td>
							
						<?}?>
												  
						
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>