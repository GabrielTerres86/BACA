<?php
/*!
 * FONTE        	: tabel_mancar.php
 * CRIAÇÃO     	    : André Clemer
 * DATA CRIAÇÃƒO  	 : Abril/2018
 * OBJETIVO     	: Tabela para a tela MANCAR
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>

<div class="divRegistros" id="divCartorios">
	<table style="table-layout: fixed;">
		<thead>
			<tr>
                <th>CPF/CNPJ</th>
				<th>Cart&oacute;rio</th>
				<th>Cidade</th>
				<th>Ativo</th>
				<th style="display:none">&nbsp;</th>
			</tr>			
		</thead>
		<tbody>
			<?php
			foreach($registros as $cartorio) {
				$nrcpf_cnpj = getByTagName($cartorio->tags,'nrcpf_cnpj');
				$nmcartorio = getByTagName($cartorio->tags,'nmcartorio');
                $idcidade = getByTagName($cartorio->tags,'idcidade');
				$dscidade = getByTagName($cartorio->tags,'dscidade');
				$flgativo = getByTagName($cartorio->tags,'flgativo');
				$idcartorio = getByTagName($cartorio->tags,'idcartorio');
			?>
			<tr>
                <td width="80"><?php echo $nrcpf_cnpj;?></td>				
				<td width="320"><?php echo $nmcartorio;?></td>
				<td width="100"><?php echo $dscidade;?></td>
				<td width="40"><?php echo $flgativo ? 'Sim' : 'Não';?></td>
				<td style="display:none">
                    <input type="hidden" id="nrcpf_cnpj" value="<? echo $nrcpf_cnpj ?>" />
                    <input type="hidden" id="nmcartorio" value="<? echo $nmcartorio ?>" />
                    <input type="hidden" id="idcidade" value="<? echo $idcidade ?>" />
                    <input type="hidden" id="dscidade" value="<? echo $dscidade ?>" />
                    <input type="hidden" id="flgativo" value="<? echo $flgativo ?>" />
                    <input type="hidden" id="idcartorio" value="<? echo $idcartorio ?>" />
				</td>
			</tr>
			<?php 
			}
			?>			
		</tbody>		
	</table>	
</div>

<div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>	
        <tr>
            <td>
            <?php
            if (isset($qtregist) and $qtregist == 0) {
                $nriniseq = 0;
            }
                // Se a paginacao nao esta na primeira, exibe botao voltar
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
                ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php
                if (($nriniseq + $nrregist) > $qtregist) {
                echo $qtregist;
                } else {
                echo ($nriniseq + $nrregist - 1);
                }
                ?> de <?php echo $qtregist; ?><?php
            }
            ?>
            </td>
            <td>
            <?php
            // Se a paginacao nao esta na ultima pagina, exibe botao proximo
            if ($qtregist > ($nriniseq + $nrregist - 1)) {
                ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?php
            } else {
                ?> &nbsp; <?php
            }
            ?>			
            </td>
        </tr>
    </table>
</div>

<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        carregarDados('<?php echo ($nriniseq - $nrregist); ?>','<?php echo $nrregist; ?>');
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        carregarDados('<?php echo ($nriniseq + $nrregist); ?>','<?php echo $nrregist; ?>');
    });

</script>