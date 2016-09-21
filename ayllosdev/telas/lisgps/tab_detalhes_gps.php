<?php
/*!
 * FONTE        : tab_detalhes_gps.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Setembro/2014
 * OBJETIVO     : Monta Tabela de dados LISGPS
 * --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
 
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
					<th>PA</th>
					<th>Caixa</th>
					<th>Operador</th>
					<th>NSU</th>
					<th>Bc/Cx</th>
					<th>Lote</th>
					<th>Vlr INSS</th>
					<th>Vlr Total</th>
				</tr>
			</thead>
			<tbody>
				<?
				if ($qtdPagamento == 0) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr><tr><td colspan="8" style="font-size:12px; text-align:center;">N&atilde;o foram encontrados registros de pagamentos.</td></tr></tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < $qtdPagamento; $i++) {
					?>
						<tr>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'cdagenci'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'cdagenci'); ?>
									  <input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($pagamento[$i]->tags,'cdcooper') ?>" />
									  <input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($pagamento[$i]->tags,'dtmvtolt') ?>" />
									  <input type="hidden" id="cdopecxa" name="cdopecxa" value="<? echo getByTagName($pagamento[$i]->tags,'cdopecxa') ?>" />
									  <input type="hidden" id="idsicred" name="idsicred" value="<? echo getByTagName($pagamento[$i]->tags,'idsicred') ?>" />
									  <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($pagamento[$i]->tags,'cdagenci') ?>" />
									  <input type="hidden" id="nrdcaixa" name="nrdcaixa" value="<? echo getByTagName($pagamento[$i]->tags,'nrdcaixa') ?>" />
									  <input type="hidden" id="nmoperad" name="nmoperad" value="<? echo getByTagName($pagamento[$i]->tags,'nmoperad') ?>" />
									  <input type="hidden" id="nrsequni" name="nrsequni" value="<? echo getByTagName($pagamento[$i]->tags,'nrsequni') ?>" />
									  <input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo getByTagName($pagamento[$i]->tags,'cdbccxlt') ?>" />
									  <input type="hidden" id="nrdolote" name="nrdolote" value="<? echo getByTagName($pagamento[$i]->tags,'nrdolote') ?>" />
									  <input type="hidden" id="vlrdinss" name="vlrdinss" value="<? echo getByTagName($pagamento[$i]->tags,'vlrdinss') ?>" />
									  <input type="hidden" id="vlrtotal" name="vlrtotal" value="<? echo getByTagName($pagamento[$i]->tags,'vlrtotal') ?>" />
									  <input type="hidden" id="tpdpagto" name="tpdpagto" value="<? echo getByTagName($pagamento[$i]->tags,'tpdpagto') ?>" />									  
									  <input type="hidden" id="cdbarras" name="cdbarras" value="<? echo getByTagName($pagamento[$i]->tags,'cdbarras') ?>" />
									  <input type="hidden" id="nrctapag" name="nrctapag" value="<? echo getByTagName($pagamento[$i]->tags,'nrctapag') ?>" />
									  <input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($pagamento[$i]->tags,'nmprimtl') ?>" />
									  <input type="hidden" id="dsidenti" name="dsidenti" value="<? echo getByTagName($pagamento[$i]->tags,'cdidenti') ?>" />
									  <input type="hidden" id="cddpagto" name="cddpagto" value="<? echo getByTagName($pagamento[$i]->tags,'cddpagto') ?>" />
									  <input type="hidden" id="mmaacomp" name="mmaacomp" value="<? echo getByTagName($pagamento[$i]->tags,'mmaacomp') ?>" />
									  <input type="hidden" id="dtvencto" name="dtvencto" value="<? echo getByTagName($pagamento[$i]->tags,'dtvencto') ?>" />
									  <input type="hidden" id="vlrjuros" name="vlrjuros" value="<? echo getByTagName($pagamento[$i]->tags,'vlrjuros') ?>" />
									  <input type="hidden" id="vlrouent" name="vlrouent" value="<? echo getByTagName($pagamento[$i]->tags,'vlrouent') ?>" />
									  <input type="hidden" id="hrtransa" name="hrtransa" value="<? echo getByTagName($pagamento[$i]->tags,'hrtransa') ?>" />
									  <input type="hidden" id="nrautdoc" name="nrautdoc" value="<? echo getByTagName($pagamento[$i]->tags,'nrautdoc') ?>" />
									  <input type="hidden" id="inpesgps" name="inpesgps" value="<? echo getByTagName($pagamento[$i]->tags,'inpesgps') ?>" />
									  <input type="hidden" id="nrseqagp" name="nrseqagp" value="<? echo getByTagName($pagamento[$i]->tags,'nrseqagp') ?>" />
									  <input type="hidden" id="nrseqdig" name="nrseqdig" value="<? echo getByTagName($pagamento[$i]->tags,'nrseqdig') ?>" />
							</td>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'nrdcaixa'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'nrdcaixa'); ?>
							</td>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'nmoperad'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'nmoperad'); ?>
							</td>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'idsicred'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'idsicred'); ?>
							</td>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'cdbccxlt'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'cdbccxlt'); ?>
							</td>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'nrdolote'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'nrdolote'); ?>
							</td>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'vlrdinss'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'vlrdinss'); ?>
							</td>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'vlrtotal'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'vlrtotal'); ?>
							</td>
						</tr>
					<? } ?>
			<? } ?>
			</tbody>
		</table>
	</div>
    <div id="divPesquisaRodape" class="divPesquisaRodape" >
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
	<div id="linha1" style="display:<?php echo ($qtdPagamento==0)? 'none' : 'block'; ?>">
		<ul class="complemento">
			<li><? echo utf8ToHtml('C&oacute;digo de Barras:'); ?></li>
			<li id="cdbarras"></li>
			<li><? echo utf8ToHtml('Forma Digita&ccedil;&atilde;o:'); ?></li>
			<li id="tpdpagto"></li>
		</ul>
	</div>
	<div id="linha2" style="display:<?php echo ($qtdPagamento==0)? 'none' : 'block'; ?>">
		<ul class="complemento">
			<li><? echo utf8ToHtml('Conta Pagadora:'); ?></li>
			<li id="nrctapag"></li>
			<li><? echo utf8ToHtml('Nome:'); ?></li>
			<li id="nmprimtl"></li>
		</ul>
	</div>
	<div id="linha3" style="display:<?php echo ($qtdPagamento==0)? 'none' : 'block'; ?>">
		<ul class="complemento">
			<li><? echo utf8ToHtml('Identificador:'); ?></li>
			<li id="dsidenti"></li>
			<li><? echo utf8ToHtml('C&oacute;d. Pagto:'); ?></li>
			<li id="cddpagto"></li>
		</ul>
	</div>
	<div id="linha4" style="display:<?php echo ($qtdPagamento==0)? 'none' : 'block'; ?>">
		<ul class="complemento">
			<li><? echo utf8ToHtml('Compet&ecirc;ncia:'); ?></li>
			<li id="mmaacomp"></li>
			<li><? echo utf8ToHtml('Vencimento:'); ?></li>
			<li id="dtvencto"></li>
		</ul>
	</div>
	<div id="linha5" style="display:<?php echo ($qtdPagamento==0)? 'none' : 'block'; ?>">
		<ul class="complemento">
			<li><? echo utf8ToHtml('Valor INSS:'); ?></li>
			<li id="vlrdinss"></li>
			<li><? echo utf8ToHtml('ATM/Multa e Juros:'); ?></li>
			<li id="vlrjuros"></li>
		</ul>
	</div>
	<div id="linha6" style="display:<?php echo ($qtdPagamento==0)? 'none' : 'block'; ?>">
		<ul class="complemento">
			<li><? echo utf8ToHtml('Valor Ouras Ent.:'); ?></li>
			<li id="vlrouent"></li>
			<li><? echo utf8ToHtml('Valor TOTAL:'); ?></li>
			<li id="vlrtotal"></li>
		</ul>
	</div>
	<div id="linha7" style="display:<?php echo ($qtdPagamento==0)? 'none' : 'block'; ?>">
		<ul class="complemento">
			<li><? echo utf8ToHtml('Hora Transa&ccedil;&atilde;o:'); ?></li>
			<li id="hrtransa"></li>
			<li><? echo utf8ToHtml('Nr. Autentica&ccedil;&atilde;o:'); ?></li>
			<li id="nrautdoc"></li>
		</ul>
	</div>
	<div id="linha8" style="display:<?php echo ($qtdPagamento==0)? 'none' : 'block'; ?>">
		<ul class="complemento">
			<li><? echo utf8ToHtml('Pago para:'); ?></li>
			<li id="inpesgps"></li>
			<li><? echo utf8ToHtml('Forma de Pagamento:'); ?></li>
			<li id="nrseqagp"></li>
		</ul>
	</div>
</div>
<script type="text/javascript">
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>