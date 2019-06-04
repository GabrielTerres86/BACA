<? 
/*!
 * FONTE        : tab_concmn.php
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 04/2019
 * OBJETIVO     : P530
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>Cooperativa</th>
					<th>Conta</th>
					<th>CPF/CNPJ</th>
					<th>Of&iacute;cio</th>
					<th>Vara</th>
				</tr>			
			</thead>
			<tbody>
				<? foreach( $registros as $item ) { ?>
					<tr>
						<td><? echo $item->nmrescop ?></td>
						<td><? echo $item->nrdconta ?></td>
						<td><? echo $item->nrcpfcnpj ?></td>
						<td><? echo $item->dsoficio ?></td>
						<td title="<? echo $item->nmjuiz; ?>">
							<? echo stringTabela($item->nmjuiz, 45, 'primeira'); ?>
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
                <?php

                if (isset($total) and $total == 0) {
                    $nriniseq = 0;
                }

                // Se a paginacao nao esta na primeira, exibe botao voltar
                if ($nriniseq > 1) {
                    ?> <a class='paginacaoAnterior'><<< Anterior</a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>
            </td>
            <td>
                <?php
                if (isset($nriniseq)) {
                    ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php
                    if (($nriniseq + $nrregist) > $total) {
                        echo $total;
                    } else {
                        echo ($nriniseq + $nrregist - 1);
                    }
                    ?> de <?php echo $total; ?><?php
                }
                ?>
            </td>
            <td>
                <?php
                // Se a paginacao nao esta na ultima pagina, exibe botao proximo
                if ($total > ($nriniseq + $nrregist - 1)) {
                    ?> <a class='paginacaoProximo'>Pr&oacute;ximo >>></a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>			
            </td>
        </tr>
    </table>
</div>

<script type="text/javascript">

    $('a.paginacaoAnterior').unbind('click').bind('click', function() {
        controlaOperacao('C',<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        controlaOperacao('C',<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>

	<div id="divBotoes">
		<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="btnVoltar();"   />			
	</div>
