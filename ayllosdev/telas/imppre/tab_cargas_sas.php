<?php
/* !
 * FONTE        : tab_cargas_sas.php
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : tabela cargas SAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

function removeFormatNumber($number){
	return str_replace('.', '', $number);
}

function formatNumber($number){
	return number_format($number, 0, ',', '.');
}
?>
<div id="tabCargas" style="display:block;">
    <div class="divRegistros">
        <table class="tituloRegistros">
            <thead>
                <tr>
                    <th>Coop.</th>
                    <th>Carga</th>
                    <th>Descri&ccedil;&atilde;o</th>
                    <th>Situa&ccedil;&atilde;o</th>
                    <th>Data</th>
                    <th>Qtd. PF</th>
                    <th>Qtd. PJ</th>
                    <th>Qtd. Tot</th>
                    <th>Limite Total</th>
                    <th>Data Inicial</th>
                    <th>Data Final</th>
                </tr>
            </thead>
<?php /*
a) dssituac: Teremos as situações da carga, sendo “Gerada”, “Importando” ou “Importada”; Mostrar depois do campo “Descrição”;
b) dthorini: Data no formato dd/mm/yy hh:mi:ss, mostrar como penúltima coluna;
c) dthorfim: Data no formato dd/mm/yy hh:mi:ss, mostrar como última coluna;
*/ ?>
            <tbody>
                <?php
                if ( $qtregist == 0 ) {
                $i = 0;?>
				<tr>
                    <td colspan="9" style="width: 80px; text-align: center;">
						<input type="hidden" id="conteudo" name="conteudo" value="<?php echo $i; ?>" />
                        <b>N&atilde;o foram encontradas Cargas registradas.</b>
                    </td>
                </tr>
                <?php	// Caso a pesquisa retornou itens, exibÃ­los em diversas linhas da tabela
                } else {
					foreach( $registros->tags as $registro ) {
                ?>
                <tr class="conteudo" id="skcarga<?php echo getByTagName($registro->tags,'skcarga'); ?>">
                    <td><input type="hidden" class="skcarga" name="skcarga" value="<?php echo $skcarga=getByTagName($registro->tags,'skcarga'); ?>" />
                        <input type="hidden" class="cdcooper" name="cdcooper" value="<?php echo $cdcooper=getByTagName($registro->tags,'cdcooper'); ?>" />
                        <input type="hidden" class="dscarga" name="dscarga" value="<?php echo $dscarga=getByTagName($registro->tags,'dscarga'); ?>" />
                        <input type="hidden" class="dssituac" name="dssituac" value="<?php echo $dssituac=getByTagName($registro->tags,'dssituac'); ?>" />
                        <input type="hidden" class="dtcarga" name="dtcarga" value="<?php echo $dtcarga=getByTagName($registro->tags,'dtcarga'); ?>" />
                        <input type="hidden" class="qtpfcarregados" name="qtpfcarregados" value="<?php echo $qtpfcarregados=getByTagName($registro->tags,'qtpfcarregados'); ?>" />
                        <input type="hidden" class="qtpjcarregados" name="qtpjcarregados" value="<?php echo $qtpjcarregados=getByTagName($registro->tags,'qtpjcarregados'); ?>" />
                        <input type="hidden" class="vllimitetotal" name="vllimitetotal" value="<?php echo $vllimitetotal=getByTagName($registro->tags,'vllimitetotal'); ?>" />
                        <input type="hidden" class="dthorini" name="dthorini" value="<?php echo $dthorini=getByTagName($registro->tags,'dthorini'); ?>" />
                        <input type="hidden" class="dthorfim" name="dthorfim" value="<?php echo $dthorfim=getByTagName($registro->tags,'dthorfim'); ?>" />
                        <?php echo "<span>$cdcooper</span>$cdcooper"; ?>
                    </td>
                    <td><?php echo "<span>$skcarga</span>$skcarga"; ?></td>
                    <td><?php echo "<span>$dscarga</span>$dscarga"; ?></td>
                    <td><?php echo "<span>$dssituac</span>$dssituac"; ?></td>
                    <td><?php echo "<span>$dtcarga</span>$dtcarga"; ?></td>
					<td><?php echo "<span>$qtpfcarregados</span>$qtpfcarregados"; ?></td>
                    <td><?php echo "<span>$qtpjcarregados</span>$qtpjcarregados"; ?></td>
					<?php $qtcarregados = removeFormatNumber($qtpfcarregados) + removeFormatNumber($qtpjcarregados); ?>
                    <td><?php echo "<span>".formatNumber($qtcarregados)."</span>".formatNumber($qtcarregados); ?></td>
                    <td><?php echo "<span>$vllimitetotal</span>$vllimitetotal"; ?></td>
                    <td ><?php echo "<span>$dthorini</span>$dthorini"; ?></td>
                    <td ><?php echo "<span>$dthorfim</span>$dthorfim"; ?></td>
                </tr>
                <?php }
                 } ?>
            </tbody>
        </table>
    </div>
    <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
                    <?php
                    if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
                    if ($nriniseq > 1) {
                    ?> <a class='paginacaoAnterior'><<< Anterior</a> <?php
                    } else {
                    ?> &nbsp; <?php
                    }
                    ?>
                </td>
                <td>
                    <?php
                    if ($nriniseq) {
                    ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <?php echo $qtregist; ?>
                    <?php } ?>
                </td>
                <td>
                    <?php
                    if ($qtregist > ($nriniseq + $nrregist - 1)) {
                    ?> <a class='paginacaoProximo'>Pr&oacute;ximo >>></a> <?php
                    } else {
                    ?> &nbsp; <?php
                    }
                    ?>
                </td>
            </tr>
        </table>
    </div>

	<div id="divBotoes" style='text-align:center; margin-bottom: 10px;' >
		<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="btnVoltar();return false;" style="float:none;">Voltar</a>
		<a href="#" class="botao adisabled" id="btLiberar" name="btLiberar" onClick="btnExecutarCarga('L');return false;" style="float:none;">Liberar</a>
		<a href="#" class="botao adisabled" id="btImportar" name="btImportar" onClick="btnExecutarCarga('I');return false;" style="float:none;">Importar</a>
		<a href="#" class="botao adisabled" id="btRejeitar" name="btRejeitar" onClick="btnExecutarCarga('R');return false;" style="float:none;">Rejeitar</a>
	</div>
</div>
<script type="text/javascript">
    $('a.paginacaoAnterior').unbind('click').bind('click', function() {
        buscaCargas(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        buscaCargas(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('#divPesquisaRodape', '#divTela').formataRodapePesquisa();
</script>
<style type="text/css" media="all">
	.adisabled {
		pointer-events: none;
		cursor: default;
		opacity: 0.6;
	}
</style>