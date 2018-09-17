<?
/*!
 * FONTE        : tab_listal.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Tabela Resultados - tela LISTAL
 * --------------
 * ALTERAÇÕES   :
 *
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

<div id="tabListal"  >
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Cooperativa'); ?></th>
					<th><? echo utf8ToHtml('Qtde Folhas');  ?></th>
					<th><? if ($tprequis == 5) {echo utf8ToHtml('Qtde A4');}  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				for ($i = 0; $i < count($registros); $i++) {
				     $totalfls += getByTagName($registros[$i]->tags,'qtfolhas');
                     $totalfa4 += getByTagName($registros[$i]->tags,'qtdflsa4');
				?>
                <tr>
                    <td><span><? echo getByTagName($registros[$i]->tags,'nmrescop'); ?></span>
                              <? echo getByTagName($registros[$i]->tags,'nmrescop'); ?>
                    </td>
                    <td><span><? echo formataNumericos("z.zzz.zzz",getByTagName($registros[$i]->tags,'qtfolhas'),"."); ?></span>
                              <? echo formataNumericos("z.zzz.zzz",getByTagName($registros[$i]->tags,'qtfolhas'),"."); ?>
                    </td>
                    <td><span><? if ($tprequis == 5) {echo formataNumericos("z.zzz.zzz",getByTagName($registros[$i]->tags,'qtdflsa4'),".");} ?></span>
                              <? if ($tprequis == 5) {echo formataNumericos("z.zzz.zzz",getByTagName($registros[$i]->tags,'qtdflsa4'),".");} ?>
                    </td>
                </tr>
				<? } ?>
				<TR>
					<TD>&nbsp;</TD>
					<TD>&nbsp;</TD>
					<TD>&nbsp;</TD>
     			</TR>
				<TR>
					<TD><b>TOTAL GERAL</b></TD>
					<TD><b><? echo formataNumericos("z.zzz.zzz",$totalfls,"."); ?> </b></TD>
					<TD><b><? if ($tprequis == 5) {echo formataNumericos("z.zzz.zzz",$totalfa4,".");} ?></b></TD>
				</TR>
			</tbody>
		</table>
	</div>
</div>

