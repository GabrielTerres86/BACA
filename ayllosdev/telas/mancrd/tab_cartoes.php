<?php
/* 
  FONTE        : tab_cartoes.php
  CRIAÇÃO      : Kelvin Souza Ott
  DATA CRIAÇÃO : 23/06/2017
  OBJETIVO     : Rotina para controlar as operações da tela MANCRD
  --------------
  ALTERAÇÕES   : 
  -------------- 
 */
?> 
<div id="divCartoes">
	<div class="divRegistros">
		<table>
			<thead>
                <tr>
                    <th><?php echo utf8ToHtml('Cartão'); ?></th>
                    <th><?php echo utf8ToHtml('Administradora'); ?></th>
                    <th><?php echo utf8ToHtml('Validade'); ?></th>
                    <th><?php echo utf8ToHtml('Situação'); ?></th>
                    <th></th>                    
                </tr>
            </thead>
			<tbody>
                <?php foreach ($registros as $r) { ?>
					<tr>
						<td>
							<span>
								<?php echo getByTagName($r->tags, 'nrcrcard') ?>
							</span>
							<?php echo getByTagName($r->tags, 'nrcrcard') ?>
						</td>
						<td>
							<span>
								<?php echo getByTagName($r->tags, 'nmresadm') ?>
							</span>
							<?php echo getByTagName($r->tags, 'nmresadm') ?>
						</td>
						<td>
							<span>
								<?php echo getByTagName($r->tags, 'dtvalida') ?>
							</span>
							<?php echo getByTagName($r->tags, 'dtvalida') ?>
						</td>
						<td>
							<span>
								<?php echo getByTagName($r->tags, 'dssitcrd') ?>
							</span>
							<?php echo getByTagName($r->tags, 'dssitcrd') ?>
						</td>	
						<td>
						  <img src="<?php echo $UrlImagens; ?>icones/ico_editar.png" onClick="mostraDetalhamento('<?php echo getByTagName($r->tags, 'nrdconta') ?>'
																											   , '<?php echo getByTagName($r->tags, 'nmprimtl') ?>'
																											   , '<?php echo getByTagName($r->tags, 'nrcrcard') ?>'
																											   , <?php echo getByTagName($r->tags, 'nrcctitg') ?>
																											   , <?php echo getByTagName($r->tags, 'cdadmcrd') ?>
																											   , '<?php echo getByTagName($r->tags, 'nrcpftit') ?>'
																											   , '<?php echo getByTagName($r->tags, 'nmtitcrd') ?>' 
																											   , '<?php echo getByTagName($r->tags, 'listadm') ?>'
																											   , <?php echo getByTagName($r->tags, 'flgdebit') ?> ); return false;" border="0" style="margin-right:5px" title="Editar Cartao"/>
																											   
						  <img src="<?php echo $UrlImagens; ?>icones/ico_reenviar.png" onClick="confirmaReenviarSolicitacao('<?php echo getByTagName($r->tags, 'nrdconta') ?>'
																														 , '<?php echo getByTagName($r->tags, 'nrcrcard') ?>'); return false;" border="0" title="Reenviar Solicitacao do Cartao"/>
						</td>
					</tr>
				<?php } ?>
			</tbody>	
		</table>
	</div>
</div>
<div id="divBotoes" style='margin-bottom :10px;border-top: 1px solid #777;'>
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>	
</div>