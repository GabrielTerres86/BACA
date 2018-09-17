<?
/*!
 * FONTE        : tab_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Outubro/2014
 * OBJETIVO     : Monta Tabela de dados REAFOR
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<div id="tabDados" style="display:block" >
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Proc.'); ?></th>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Operador');  ?></th>
					<th><? echo utf8ToHtml('CPF/CNPJ');  ?></th>
					<th><? echo utf8ToHtml('Associado');  ?></th>
					<th><? echo utf8ToHtml('Conta/dv');  ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($registros) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr><tr><td colspan="6" style="font-size:12px; text-align:center;">N&atilde;o foram encontrados registros no per&iacute;odo informado.</td></tr></tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($registros); $i++) {
					?>
						<tr>
							<td><span><input type="checkbox" id="chk" name="chk_" value="<? echo getByTagName($registros[$i]->tags,'indrowid'); ?>" <?php echo (getByTagName($registros[$i]->tags,'flenvarq')==1 ? 'checked' : '');?> disabled ></span>
							    <input type="checkbox" id="chk" name="chk_<? echo $i ?>" value="<? echo getByTagName($registros[$i]->tags,'indrowid'); ?>" <?php echo (getByTagName($registros[$i]->tags,'flenvarq')==1 ? 'checked' : '');?>  disabled>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'dtmvtolt'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'dtmvtolt'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'cdoperad'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'cdoperad'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'nrcpfcgc'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'nrcpfcgc'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'nmprimtl'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'nmprimtl'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'nrdconta'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'nrdconta'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'nrctremp'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'nrctremp'); ?>
							</td>
						</tr>
					<? } ?>
			<? } ?>
			</tbody>
		</table>
	</div>
    <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
                    <?
                        //
                        if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;

                        // Se a paginação não está na primeira, exibe botão voltar
                        if ($nriniseq > 1) {
                            ?> <a class='paginacaoAnt'><<< Anterior</a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
                <td>
                    <?
                        if ($nriniseq) {
                            ?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
                    <?  } ?>
                </td>
                <td>
                    <?
                        // Se a paginação não está na ultima página, exibe botão proximo
                        if ($qtregist > ($nriniseq + $nrregist - 1)) {
                            ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
            </tr>
        </table>
    </div>
</div>
<script type="text/javascript">
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>