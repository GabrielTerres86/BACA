<?php
	/* !
	 * FONTE        : tab_consulta.php
	 * CRIA��O      : Jean Michel
	 * DATA CRIA��O : 07/07/2014
	 * OBJETIVO     : Tabela de Registros de Taxas - tela INDICE
	 * --------------
	 * ALTERA��ES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	 *
	 * --------------
	 */

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>
	<form action="" method="post" id="frmTaxas" name="frmTaxas">
		<div id="tabIndice">
			<div class="divRegistros">
				<table class="tituloRegistros">
					<thead>
						<tr>
							<th>Data Per&iacute;odo</th>
							<th>Taxa do Dia</th>
							<th>Taxa M&ecirc;s</th>
							<th>Taxa Ano</th>
							<th>Taxa Acumulada</th>
						</tr>
					</thead>
					<tbody>
						<?php foreach ($registros as $registro) { ?>
							<tr id="<?php echo($registro->tags[0]->cdata); ?>">
								<td>
									<?php echo($registro->tags[0]->cdata); ?>
								</td>
								<td>
									<span><?php echo($registro->tags[1]->cdata); ?></span>
									<?php echo str_replace('.',',',$registro->tags[1]->cdata); ?>
								</td>
								<td>
									<span><?php echo($registro->tags[2]->cdata); ?></span>
									<?php echo str_replace('.',',',$registro->tags[2]->cdata); ?>
								</td>
								<td>
									<span><?php echo($registro->tags[3]->cdata); ?></span>
									<?php echo str_replace('.',',',$registro->tags[3]->cdata); ?>
								</td>
								<td>
									<span><?php echo($registro->tags[4]->cdata); ?></span>
									<?php echo str_replace('.',',',$registro->tags[4]->cdata); ?>
								</td>
							</tr>
						<?php } ?>
					</tbody>
				</table>
			</div>
		</div>
	</form>

	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td>
					<?php
					if (isset($qtdregist) and $qtdregist == 0)
						$nriniseq = 0;

					// Se a pagina��o n�o est� na primeira, exibe bot�o voltar
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
                        // Se a pagina��o n�o est� na &uacute;ltima p�gina, exibe bot�o proximo
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

        <div id="divBotoes">
            <a href="#" class="botao" id="btVoltar" name="btVoltar" onclick="fechaConsulta(); return false;" >Voltar</a>
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