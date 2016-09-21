<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Tabela - tela DEVOLU
 * --------------
 * ALTERAÇÕES   : 15/04/2015 - #273953 Inclusao das colunas Banco e Agencia para ficar conforme tela do ambiente caracter (Carlos)
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

<div id="tabDevoluConta" style="display:none" >
	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Bco'); ?></th>
					<th><? echo utf8ToHtml('Ag'); ?></th>
                	<th><? echo utf8ToHtml('Cheque');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
					<th><? echo utf8ToHtml('Sit.');  ?></th>
                    <th><? echo utf8ToHtml('Alinea');  ?></th>
					<th><? echo utf8ToHtml('Operador');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				for ($i = 0; $i < count($lancamento); $i++) {
                ?>	<tr>
						<th><input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($lancamento[$i]->tags,'cdcooper') ?>" />
							<input type="hidden" id="dsbccxlt" name="dsbccxlt" value="<? echo getByTagName($lancamento[$i]->tags,'dsbccxlt') ?>" />
							<input type="hidden" id="banco"    name="banco"    value="<? echo getByTagName($lancamento[$i]->tags,'banco') ?>" />
							<input type="hidden" id="nrdctitg" name="nrdctitg" value="<? echo getByTagName($lancamento[$i]->tags,'nrdctitg') ?>" />
							<input type="hidden" id="cdbanchq" name="cdbanchq" value="<? echo getByTagName($lancamento[$i]->tags,'cdbanchq') ?>" />
							<input type="hidden" id="cdagechq" name="cdagechq" value="<? echo getByTagName($lancamento[$i]->tags,'cdagechq') ?>" />
							<input type="hidden" id="nrctachq" name="nrctachq" value="<? echo getByTagName($lancamento[$i]->tags,'nrctachq') ?>" />
							<input type="hidden" id="cddsitua" name="cddsitua" value="<? echo getByTagName($lancamento[$i]->tags,'cddsitua') ?>" />
							<input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo getByTagName($lancamento[$i]->tags,'nrdocmto') ?>" />
							<input type="hidden" id="flag"     name="flag"     value="<? echo getByTagName($lancamento[$i]->tags,'flag')     ?>" />
							<input type="hidden" id="nrdrecid" name="nrdrecid" value="<? echo getByTagName($lancamento[$i]->tags,'nrdrecid') ?>" />
							<input type="hidden" id="nmoperad" name="nmoperad" value="<? echo getByTagName($lancamento[$i]->tags,'nmoperad') ?>" />
							<input type="hidden" id="vllanmto" name="vllanmto" value="<? echo getByTagName($lancamento[$i]->tags,'vllanmto') ?>" />
							<input type="hidden" id="cdalinea" name="cdalinea" value="<? echo getByTagName($lancamento[$i]->tags,'cdalinea') ?>" />
						</th>

						<td><span><? echo getByTagName($lancamento[$i]->tags,'banco'); ?></span>
							      <? echo getByTagName($lancamento[$i]->tags,'dsbccxlt'); ?>
						</td>
						
						<td><span><? echo getByTagName($lancamento[$i]->tags,'cdagechq'); ?></span>
							      <? echo getByTagName($lancamento[$i]->tags,'cdagechq'); ?>
						</td>

						<td><span><? echo getByTagName($lancamento[$i]->tags,'nrdocmto'); ?></span>
							      <? echo getByTagName($lancamento[$i]->tags,'nrdocmto'); ?>
						</td>
						<td><span><? echo formataMoeda(getByTagName($lancamento[$i]->tags,'vllanmto')) ; ?></span>
								  <? echo formataMoeda(getByTagName($lancamento[$i]->tags,'vllanmto')) ; ?>
						</td>
						<td><span><? echo getByTagName($lancamento[$i]->tags,'dssituac');?></span>
								  <? echo getByTagName($lancamento[$i]->tags,'dssituac'); ?>
						</td>
						<td><span><? echo getByTagName($lancamento[$i]->tags,'cdalinea'); ?></span>
							      <? echo getByTagName($lancamento[$i]->tags,'cdalinea'); ?>
						</td>
						<td><span><? echo getByTagName($lancamento[$i]->tags,'nmoperad'); ?></span>
							      <? echo getByTagName($lancamento[$i]->tags,'nmoperad'); ?>
						</td>
					</tr>
                <? } ?>
            </tbody>
		</table>
	</div>
	
</div>