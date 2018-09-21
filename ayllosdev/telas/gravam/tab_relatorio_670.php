<? 
/*!
 * FONTE        : tab_relatorio_670.php
 * CRIAÇÃO      : Thaise Medeiros - Envolti
 * DATA CRIAÇÃO : 12/09/2018
 * OBJETIVO     : Tabela que apresenta o relatório 670.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>

<div id="divRel670" style="display:block">
	<div class="divRegistros">
		<table class="">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Coop'); ?></th>
					<th><? echo utf8ToHtml('PA');  ?></th>
					<th><? echo utf8ToHtml('Operação');  ?></th>
					<th><? echo utf8ToHtml('Lote');  ?></th>
					<th><? echo utf8ToHtml('Conta/DV');  ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Chassi');  ?></th>
					<th><? echo utf8ToHtml('Bem');  ?></th>
					<th><? echo utf8ToHtml('Data Envio');  ?></th>
					<th><? echo utf8ToHtml('Data Retorno');  ?></th>
					<th><? echo utf8ToHtml('Situação');  ?></th>
				</tr>
			</thead>
			<tbody><?
				if ( count($registrosSemRet) == 0 && count($registrosComSuc) == 0 && count($registrosComErro) == 0) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="11" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros para exibir.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($registrosSemRet); $i++) { ?>
						<tr id="linObsClick_<? echo $i; ?>">
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'cdcooper'); ?></span>
									  <? echo getByTagName($registrosSemRet[$i]->tags,'cdcooper'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'cdagenci'); ?></span>
									  <? echo getByTagName($registrosSemRet[$i]->tags,'cdagenci'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'dsoperac'); ?></span>
									  <? echo getByTagName($registrosSemRet[$i]->tags,'dsoperac'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'nrseqlot'); ?></span>
									  <? echo getByTagName($registrosSemRet[$i]->tags,'nrseqlot'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'nrdconta'); ?></span>
									  <? echo getByTagName($registrosSemRet[$i]->tags,'nrdconta'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'nrctrpro'); ?></span>
									  <? echo getByTagName($registrosSemRet[$i]->tags,'nrctrpro'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'dschassi'); ?></span>
									  <? echo getByTagName($registrosSemRet[$i]->tags,'dschassi'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'dsbemfin'); ?></span>
								      <? echo getByTagName($registrosSemRet[$i]->tags,'dsbemfin'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'dtenvgrv'); ?></span>
								      <? echo getByTagName($registrosSemRet[$i]->tags,'dtenvgrv'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'dtretgrv'); ?></span>
								      <? echo getByTagName($registrosSemRet[$i]->tags,'dtretgrv'); ?>
							</td>
							<td>
								<span><? echo getByTagName($registrosSemRet[$i]->tags,'dssituac'); ?></span>
									  <? echo getByTagName($registrosSemRet[$i]->tags,'dssituac'); ?>
							</td>
						</tr>
			<?  	}
				} ?>	
			</tbody>
		</table>
	</div>
	
	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td>
					<?php
					if (isset($qtdregist) and $qtdregist == 0)
						$nriniseq = 0;

					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) {
						?> <a class='paginacaoAnt'><<< Anterior</a> <?php
					} else {
						?> &nbsp; <?php
						}
						?>
                </td>
                <td>
                    <?php
                    if (isset($nriniseq)) {
                        ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php if (($nriniseq + $nrregist) > $qtdregist) {
                    echo $qtdregist;
                } else {
                    echo ($nriniseq + $nrregist - 1);
                } ?> de <?php echo $qtdregist; ?><?
                        }
                        ?>
                    </td>
                    <td>
                        <?php
                        // Se a paginação não está na &uacute;ltima página, exibe botão proximo
                        if ($qtdregist > ($nriniseq + $nrregist - 1)) {
                            ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?php
            } else {
                ?> &nbsp; <?php
            }
            ?>			
                    </td>
                </tr>
            </table>
        </div>

		
	<div id="divObservacao" style="display:none;">
		<table style="border-collapse: collapse; width: 100%; margin-top: 3%;">
			<thead>
				<tr style="border-bottom: 1px dotted #999;">
					<th style="font-size: 12px; height: 22px; padding: 0px 5px; cursor: pointer; border-right: 1px dotted #999; background-color: #f7d3ce; text-align: center;" ><? echo utf8ToHtml('Retorno');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? // Carrega as observacoes
				for ($i = 0; $i < count($registrosSemRet); $i++) { 
					$dsretor = getByTagName($registrosSemRet[$i]->tags,'desretor') != '' ? getByTagName($registrosSemRet[$i]->tags,'desretor') : 'Sem Retorno para o registro' ;
					?>
					<tr class="linObs" id="linObs_<? echo $i; ?>" style="height: 16px; background-color: #ffbaad;">
						<td style="padding: 0px 5px; border-right: 1px dotted #999; font-size: 12px; color: #333; text-align: left;" ><? echo $dsretor; ?></td>
					</tr>
				<? } 
				?> 
				<tr><td>&nbsp;</td></tr>
			</tbody>
		</table>
	</div>
</div>

<script type="text/javascript">
    
	$('#cddopcao', '#frmCab').attr('disabled', true);
    //$('#cddindexC', '#frmCab').attr('disabled', true);
    
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaIndice( <?php echo "'".($nriniseq - $nrregist)."'"; ?> , <?php echo "'".$nrregist."'"; ?> );
    });
	
    $('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaIndice( <?php echo "'".($nriniseq + $nrregist)."'"; ?> , <?php echo "'".$nrregist."'"; ?> );
    });
    
	$('#divPesquisaRodape').formataRodapePesquisa();

</script>