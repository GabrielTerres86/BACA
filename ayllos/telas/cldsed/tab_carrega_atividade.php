<?
/*!
 * FONTE        : tab_carrega_atividade.php						Última alteração: 17/10/2016
 * CRIAÇÃO      : Cristian Filipe (GATI)        
 * DATA CRIAÇÃO : 03/09/2013
 * OBJETIVO     : Tabela para opção T
 * --------------
 * ALTERAÇÕES   : 
 *			     05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
		
				 08/08/2016 - Ajuste para inclusão de controle de paginação
							  (Adriano - SD 495725).
 
                 17/10/2016 - #524686 Correção de format do nrdconta (Carlos) 
 * --------------
 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	isPostMethod();

?>
<div id="divTabListaMovimentacoes">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Conta/DV');  ?></th>
					<th><? echo utf8ToHtml('Rendimento');  ?></th>
					<th><? echo utf8ToHtml('Credito');  ?></th>
					<th><? echo utf8ToHtml('Credito/Renda');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				 foreach($pesquisa as $values){  ?>
					<tr>
						<td>
							<input type="hidden" value="<? echo getByTagName($values->tags, 'tpvincul');?>" id="htpvincul">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'infrepcf');?>" id="hinfrepcf">		
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsstatus');?>" id="hdsstatus"/>
							<input type="hidden" value="<? echo getByTagName($values->tags, 'cddjusti')." - ".getByTagName($values->tags, 'dsdjusti');?>" id="hcddjusti">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsobserv');?>" id="hdsobserv">
							<input type="hidden" value="<? echo getByTagName($values->tags, 'dsobsctr');?>" id="hdsobsctr">	
							
							<span><? echo getByTagName($values->tags, 'cdagenci') ; ?></span>
									  <? echo getByTagName($values->tags, 'cdagenci') ;?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'dtmvtolt'); ?></span>
							      <? echo getByTagName($values->tags, 'dtmvtolt'); ?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'nrdconta') ;?></span>
							      <? echo mascara(getByTagName($values->tags, 'nrdconta'),'####.###.#');?>
						</td>
						<td>
							<span><? echo converteFloat(getByTagName($values->tags, 'vlrendim') ,'MOEDA'); ?></span>
							      <? echo formataMoeda(getByTagName($values->tags, 'vlrendim')) ;?>
						</td>
						<td>
							<span><? echo converteFloat(getByTagName($values->tags, 'vltotcre') ,'MOEDA'); ?></span>
								  <? echo formataMoeda(getByTagName($values->tags, 'vltotcre')); ?>
						</td>
						<td>
							<span><? echo getByTagName($values->tags, 'qtultren') ;?></span>
							      <? echo mascara(getByTagName($values->tags, 'qtultren'),'###.###.###') ;?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	<div id="divPesquisaRodape" class="divPesquisaRodape">
      <table>
        <tr>
          <td>
            <?if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;

			if ($nriniseq > 1) {?> 
				<a class='paginacaoAnt'><<< Anterior</a> 
			<?} else {?> 
				&nbsp; 
			<?}?>						
        
          </td>
          <td>
            <? if (isset($nriniseq)) { ?>
				Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
			<? } ?>					
        
          </td>
          <td>
            <? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
				<a class="paginacaoProx">Pr&oacute;ximo >>></a>

            <? }?>
				
          </td>
        </tr>
      </table>
</div>
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		realizaOperacao("T", <? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?> );
    });

	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		realizaOperacao("T", <? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);

  });

  $('#divPesquisaRodape').formataRodapePesquisa();
 
</script>