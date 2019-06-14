<?php
/*!
 * FONTE        : tab_impres.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 31/08/2011 
 * OBJETIVO     : Tabela que apresenta a consulta IMPRES
 * --------------
 * ALTERAÇÕES   : 29/11/2012 - Alterado botões do tipo tag <input> para tag <a> novo layout (Daniel).
 *				  
 *				  30/12/2014 - Padronizando a mascara do campo nrctremp. 10 Digitos - Campos usados apenas para visualização
 *					 		   8 Digitos - Campos usados para alterar ou incluir novos contratos (Kelvin - SD 233714).
 *
 *				  03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div id="tabImpres" style="display:none" >
	<div class="divRegistros">	
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th>Conta</th>
					<th>Tipo</th>
					<th>Dt. Inic</th>
					<th>Dt. Final</th>
					<th>Trf</th>
					<th>Lista</th>
					<th>Sel</th>
					<th>Contrato</th>
					<th>Aplica&ccedil;</th>
					<th>Ano</th>
					<th>Quando</th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach ( $registro as $r ) { 
				
				$nrdconta =  getByTagName($r->tags,'nrdconta');
				$dsextrat =  getByTagName($r->tags,'dsextrat');
				$dtrefere =  getByTagName($r->tags,'dtrefere') != '' ? getByTagName($r->tags,'dtrefere') : '' ;
				$dtreffim =  getByTagName($r->tags,'dtreffim') != '' ? getByTagName($r->tags,'dtreffim') : '' ;
				$flgtarif = (getByTagName($r->tags,'tpextrat') == 1  ? (getByTagName($r->tags,'flgtarif') == 'yes' ? 'Sim' : 'Nao') : '') ;
                $tpmodelo =  getByTagName($r->tags,'tpmodelo');
				$inrelext =  getByTagName($r->tags,'inrelext') > 0   ? getByTagName($r->tags,'inrelext') : '' ;
				$inselext = (getByTagName($r->tags,'inselext') > 0 and getByTagName($r->tags,'tpextrat') > 1) ? getByTagName($r->tags,'inselext') : '' ;
				$nrctremp =  getByTagName($r->tags,'nrctremp') > 0   ? mascara(getByTagName($r->tags,'nrctremp'),'#.###.###.###')  : '' ;
				$nraplica =  getByTagName($r->tags,'nraplica') > 0   ? mascara(getByTagName($r->tags,'nraplica'),'####.###')  : '' ;
				$nranoref =  getByTagName($r->tags,'nranoref') > 0   ? getByTagName($r->tags,'nranoref')  : '' ;
				$flgemiss =  getByTagName($r->tags,'flgemiss') == 'no' ? 'Process' : 'Agora' ;
				
				?>
					<tr>
						<td><span><? echo $nrdconta; ?></span>
							     <? echo formataContaDV($nrdconta); ?>
						</td>
						<td><span><? echo $dsextrat; ?></span>
							      <? echo $dsextrat; ?>
						</td>
						<td><span><? echo dataParaTimestamp($dtrefere); ?></span>
							      <? echo $dtrefere; ?>
						</td>
						<td><span><? echo dataParaTimestamp($dtreffim); ?></span>
							      <? echo $dtreffim; ?>
						</td>
						<td><span><? echo $flgtarif ?></span>
							      <? echo $flgtarif ?>
						</td>
						<td><span><? echo $inrelext ?></span>
							      <? echo $inrelext ?>
						</td>
						<td><span><? echo $inselext ?></span>
							      <? echo $inselext ?>
						</td>
						<td><span><? echo $nrctremp ?></span>
							      <? echo $nrctremp ?>
						</td>
						<td><span><? echo $nraplica ?></span>
							      <? echo $nraplica ?>
						</td>
						<td><span><? echo $nranoref ?></span>
							      <? echo $nranoref ?>
						</td>
						<td><span><? echo $flgemiss ?></span>
							      <? echo $flgemiss ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>



<div id="divBotoes" style="padding-bottom:8px;" style="display:none">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btContinuar" onclick="controlaOk(3); return false;">Continuar</a>
</div>																		
