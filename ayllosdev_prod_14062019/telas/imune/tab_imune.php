<?
/*!
 * FONTE        : IMUNE.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Tabela - tela IMUNE
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

<div id="tabImune" style="display:block" >
  	<div class="divRegistros">
	    <table class="tituloRegistros" >
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Conta/dv'); ?></th>
					<th><? echo utf8ToHtml('Titular');  ?></th>
				</tr>
			</thead>
			<tbody>
                <?

                $data = getByTagName($imunidade[0]->tags,'dtdaprov') != '' ? getByTagName($imunidade[0]->tags,'dtdaprov') : getByTagName($imunidade[0]->tags,'dtcancel');
                $qtd = count($imunidade);

				for ($i = 0; $i < count($associado); $i++) {
				?>
					<tr>
                        <td><span><? echo getByTagName($associado[$i]->tags,'cdagenci'); ?></span>
							      <? echo getByTagName($associado[$i]->tags,'cdagenci'); ?>
						</td>
                        <td><span><? echo formataContaDV(getByTagName($associado[$i]->tags,'nrdconta')); ?></span>
							      <? echo formataContaDV(getByTagName($associado[$i]->tags,'nrdconta')); ?>
						</td>
                        <td><span><? echo getByTagName($associado[$i]->tags,'nmprimtl'); ?></span>
							      <? echo getByTagName($associado[$i]->tags,'nmprimtl'); ?>
						</td>
					</tr>
                <? } ?>
                <tr>
                    <input type="hidden" id="dssitcad" name="dssitcad" value="<? echo getByTagName($imunidade[0]->tags,'dssitcad'); ?>" />
                    <input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($associado[0]->tags,'nmprimtl'); ?>" />
                    <input type="hidden" id="cddentid" name="cddentid" value="<? echo getByTagName($imunidade[0]->tags,'cddentid'); ?>" />
                    <input type="hidden" id="dsdentid" name="dsdentid" value="<? echo getByTagName($imunidade[0]->tags,'dsdentid'); ?>" />
                </tr>
            </tbody>
		</table>
	</div>
    <br style="clear:both" />
    <form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block;" >
        <fieldset>
            <legend><b><? echo utf8ToHtml('Detalhe da Pesquisa') ?></b></legend>

            <? $cdsitcad = getByTagName($imunidade[0]->tags,'cdsitcad'); ?>

            <label for="cdsitcad"><? echo utf8ToHtml('Situação:'); ?></label>
            <select id="cdsitcad" name="cdsitcad" onChange="liberaCampoDescricao(this.value);" >
                <option value="0" <? if ($cdsitcad == 0) { echo "selected";} ?>> 0 - Pendente </option>
                <option value="1" <? if ($cdsitcad == 1) { echo "selected";} ?>> 1 - Aprovado </option>
                <option value="2" <? if ($cdsitcad == 2) { echo "selected";} ?>> 2 - N&atilde;o Aprovado </option>
                <option value="3" <? if ($cdsitcad == 3) { echo "selected";} ?>> 3 - Cancelado </option>
            </select>

            <label for="dtdaprov"><? echo utf8ToHtml('Data:'); ?></label>
            <input id="dtdaprov" name="dtdaprov" value="<? echo $data ?>" />
            <br style="clear:both" />

            <label for="dscancel"><? echo utf8ToHtml('Motivo Nao Apr:'); ?></label>
            <input id="dscancel" name="dscancel" value="<? echo getByTagName($imunidade[0]->tags,'dscancel'); ?>" />

            <label for="nmoperad"><? echo utf8ToHtml('Operador:'); ?></label>
            <input id="nmoperad" name="nmoperad" value="<? echo getByTagName($imunidade[0]->tags,'nmoperad'); ?>" />
            <br style="clear:both" />
             
        </fieldset>
    </form>
</div>
