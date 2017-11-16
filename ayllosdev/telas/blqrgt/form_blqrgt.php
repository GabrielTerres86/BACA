<?php
/*!
 * FONTE        : form_blqrgt.php                        Última alteração: 
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 10/11/2017
 * OBJETIVO     : Desbloqueia por cobertura de operação de crédito
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 ?>
 <fieldset style="padding: 10px <? echo $cddopcao == 'L' ? '110px' : '180px';?> 5px <? echo $cddopcao == 'L' ? '110px' : '180px';?>;">
  <legend align="center">Bloqueios de Aplica&ccedil;&atilde;o </legend>
  <div id="divBloqueiosAplicacao" class="divRegistros">
	<table>
	  <thead>
		<tr>
			<th>Tipo</th>
			<th>Aplica&ccedil;&atilde;o</th>
			<th>Saldo</th>
		<? if ($cddopcao == 'L') { ?>
			<th>Desbloquear</th>
		<? } ?>
		</tr>
	  </thead>
	  <tbody>
		<? foreach( $bloqueios as $bloqueio ) { ?>
		  <tr id="trBloqueio" style="cursor: pointer;">
			<td align="center"><? echo $bloqueio->dstipapl ?></td>
			<td align="center"><? echo $bloqueio->nrctrrpp ?></td>
			<td align="center"><? echo $bloqueio->vlsdrdpp ?></td>
			<? if ($cddopcao == 'L') { ?>
				<td align="center" style="text-align:center">
					<img src="../../imagens/geral/servico_nao_ativo.gif" width="16" height="16" title="Remover" style="cursor: pointer;" onclick="confirmaDesbloqueioApl('<? echo $bloqueio->tpaplica; ?>', '<? echo $bloqueio->idtipapl; ?>', '<? echo $bloqueio->nrctrrpp; ?>', '<? echo $bloqueio->nmprodut; ?>');"></img>
				</td>
			<? } ?>
		  </tr>
		<? } ?>
	  </tbody>
	</table>
  </div>
</fieldset>

<fieldset style="padding: 10px <? echo $cddopcao == 'L' ? '40px' : '50px';?> 5px <? echo $cddopcao == 'L' ? '40px' : '50px';?>;">
  <legend align="center">Bloqueios por Cobertura de Opera&ccedil;&atilde;o de Cr&eacute;dito</legend>
  <div id="divBloqueiosCobertura" class="divRegistros" style="text-align: center;">
	<?php if ($countBloqueiosCobertura > 0) { ?>
		<table>
		  <thead>
			<tr>
			  <th>Tipo</th>
			  <th>Conta</th>
			  <th>Contrato</th>
			  <th>Saldo Dev/Limite</th>
			  <th>Bloqueado</th>
			  <th>Desbloquear</th>
			</tr>
		  </thead>
		  <tbody>
			<? foreach( $bloqueiosCobertura as $registro ) { ?>
			  <tr id="trBloqueio" style="cursor: pointer;">
				<td align="center">
				  <? echo getByTagName($registro->tags,'tpcontrato'); ?>
				  <input type="hidden" id="hd_idcobertura" value="<? echo getByTagName($registro->tags,'idcobertura'); ?>" />
				</td>
				<td align="center"><? echo getByTagName($registro->tags,'nrdconta') ?></td>
				<td align="center"><? echo getByTagName($registro->tags,'nrcontrato') ?></td>
				<td align="center"><? echo getByTagName($registro->tags,'vlopera') ?></td>
				<td align="center"><? echo getByTagName($registro->tags,'valbloque') ?></td>
				<td align="center" style="text-align:center">
					<img src="../../imagens/geral/servico_nao_ativo.gif" width="16" height="16" title="Remover" style="cursor: pointer;" onclick="confirmaDesbloqueioCob('<? echo getByTagName($registro->tags,'idcobertura'); ?>', '<? echo getByTagName($registro->tags,'vlopera') ?>');"></img>
				</td>
			  </tr>
			<? } ?>
		  </tbody>
		</table>
	<?php
	} else {
		echo "Sem aplica&ccedil;&otilde;es / cobertura bloqueadas para a conta informada.";
	} ?>
  </div>
</fieldset>