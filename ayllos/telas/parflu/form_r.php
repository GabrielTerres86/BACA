<?
/*!
 * FONTE        	: form_r.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Outubro/2016
 * OBJETIVO     	: Form para a opcao R
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>
<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>

<form id="frmParflu" name="frmParflu" class="formulario">
    <input name="hdnremessa" id="hdnremessa" type="hidden" value="<?php echo $remessa; ?>" />
    
    <div id="divRemessa1" style="margin-top:20px; display:none; text-align: center;" >
		<label for="remessa">Remessa:</label>
        <select id="remessa" name="remessa">
            <?php
                $arrRemessa = array();
                foreach ($regremess as $reg) {
                    $cdremessa          = getByTagName($reg->tags,'CDREMESSA');
                    $nmremessa          = getByTagName($reg->tags,'NMREMESSA');
                    $tpfluxo_entrada    = getByTagName($reg->tags,'TPFLUXO_ENTRADA');
                    $tpfluxo_saida      = getByTagName($reg->tags,'TPFLUXO_SAIDA');
                    $flremessa_dinamica = getByTagName($reg->tags,'FLREMESSA_DINAMICA');

                    $arrRemessa[$cdremessa]['NMREMESSA']          = $nmremessa;
                    $arrRemessa[$cdremessa]['TPFLUXO_ENTRADA']    = $tpfluxo_entrada;
                    $arrRemessa[$cdremessa]['TPFLUXO_SAIDA']      = $tpfluxo_saida;
                    $arrRemessa[$cdremessa]['FLREMESSA_DINAMICA'] = $flremessa_dinamica;

                    echo '<option value="'.$cdremessa.'">'.$cdremessa.' - '.$nmremessa.'</option>';
                }
            ?>
        </select>
        <a href="#" class="botao" id="btVoltar"  onClick="btnVoltar();return false;" style="text-align: right; float: none;">Voltar</a>
        <a href="#" class="botao" id="btProsseguir" onClick="mostraOpcaoR();" style="text-align: right; float: none;">Prosseguir</a>
	</div>

    <div id="divRemessa2" style="margin-top:20px; display:none; text-align: center;" >
        <table cellpadding="10" cellspacing="5">
        <tr style="font-weight:bold; color:#333;font-size:12px;">
            <td>Remessa</td>
            <td>&nbsp;</td>
            <td>Fluxo do Dia<br />na Entrada</td>
            <td>&nbsp;</td>
            <td>Fluxo do Dia<br />na Saída</td>
            <td>&nbsp;</td>
            <td>Remessa<br />Dinâmica</td>
        </tr>
        <tr>
            <td>
                <input type="text" name="cdremessa" id="cdremessa" value="<?php echo $remessa; ?>" />
                <input type="text" name="nmremessa" id="nmremessa" value="<?php echo $arrRemessa[$remessa]['NMREMESSA']; ?>" />
            </td>
            <td>&nbsp;</td>
            <td>
                <select id="tpfluxo_e" name="tpfluxo_e">
                <option value="1" <?php echo ($arrRemessa[$remessa]['TPFLUXO_ENTRADA'] == 1 ? 'selected' : ''); ?>>Realizado</option>
                <option value="3" <?php echo ($arrRemessa[$remessa]['TPFLUXO_ENTRADA'] == 3 ? 'selected' : ''); ?>>Projetado</option>
                </select>
            </td>
            <td>&nbsp;</td>
            <td>
                <select id="tpfluxo_s" name="tpfluxo_s">
                <option value="2" <?php echo ($arrRemessa[$remessa]['TPFLUXO_SAIDA'] == 2 ? 'selected' : ''); ?>>Realizado</option>
                <option value="4" <?php echo ($arrRemessa[$remessa]['TPFLUXO_SAIDA'] == 4 ? 'selected' : ''); ?>>Projetado</option>
                </select>
            </td>
            <td>&nbsp;</td>
            <td>
                <select id="flremdina" name="flremdina">
                <option value="1" <?php echo ($arrRemessa[$remessa]['FLREMESSA_DINAMICA'] == 1 ? 'selected' : ''); ?>>Sim</option>
                <option value="0" <?php echo ($arrRemessa[$remessa]['FLREMESSA_DINAMICA'] == 0 ? 'selected' : ''); ?>>Não</option>
                </select>
            </td>
        </tr>
        </table>

        <br style="clear:both" />

        <fieldset id="fsetFormularioInc" name="fsetFormularioInc" style="padding:0px; margin:0px;">
        <legend> Incluir hist&oacute;rico </legend>
            <table width="630" style="margin: 5px 0px 10px 10px;">
            <tr>
                <td>Institui&ccedil;&atilde;o Financeira</td>
                <td>Movimento</td>
                <td>C&oacute;digo</td>
                <td>Descri&ccedil;&atilde;o</td>
                <td>Tipo</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td>
                    <select id="cdbccxlt" name="cdbccxlt">
                    <?php
                        foreach ($arrBancos as $cdbanco => $nmbanco) {
                            echo '<option value="'.$cdbanco.'">'.$nmbanco.'</option>';
                        }
                    ?>
                    </select>
                </td>
                <td>
                    <select id="tpfluxo" name="tpfluxo">
                    <option value="E">Entrada</option>
                    <option value="S">Saída</option>
                    </select>
                </td>
                <td><input type="text" name="cdhistor" id="cdhistor" /> <a style="padding: 3px 0 0 3px;" href="#" onClick="mostraPesquisaHistor();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a></td>
                <td><input type="text" name="dshistor" id="dshistor" /></td>
                <td><input type="text" name="tphistor" id="tphistor" /></td>
                <td><a href="#" class="botao" id="btAdicionar"  onClick="validaInclusao();return false;" style="text-align: right; float: none;">Adicionar</a></td>
            </tr>
            </table>
        </fieldset>

        <fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; margin-top:20px; padding-bottom:10px;">
        <legend> Hist&oacute;ricos vinculados </legend>
            <div id="divHistor" class="divRegistros">
                <table>
                    <thead>
                        <tr>
                            <th width="120">Inst. Financeira</th>
                            <th width="80">Movimento</th>
                            <th width="50">C&oacute;digo</th>
                            <th>Descri&ccedil;&atilde;o</th>
                            <th width="50">Tipo</th>
                            <th width="60">Remover</th>
                        </tr>
                    </thead>
                    <tbody id="tbodyHistor">
                    <?php
                        foreach ($reghistor as $reg) {
                            $cdhistor = getByTagName($reg->tags,'CDHISTOR');
                            $dshistor = getByTagName($reg->tags,'DSHISTOR');
                            $tphistor = getByTagName($reg->tags,'TPHISTOR');
                            $cdbanco  = getByTagName($reg->tags,'CDBCCXLT');
                            $dsbanco  = $arrBancos[$cdbanco];
                            $tpfluxo  = getByTagName($reg->tags,'TPFLUXO');
                            $lnhistor = $remessa.'_'.$cdhistor.'_'.substr($tpfluxo, 0, 1).'_'.$cdbanco;
                            echo '
                            <tr id="'.$lnhistor.'">
                                <td width="120"><span>'.$cdbanco.$tpfluxo.'</span>'.$dsbanco.'</td>
                                <td width="80">'.$tpfluxo.'</td>
                                <td width="50">'.$cdhistor.'</td>
                                <td>'.$dshistor.'</td>
                                <td width="50">'.$tphistor.'</td>
                                <td width="60"><img onclick="confirmaExclusao(\''.$lnhistor.'\');" style="cursor:hand;" src="../../imagens/geral/panel-error_16x16.gif" width="13" height="13" /></td>
                            </tr>';
                        }
                    ?>
                    </tbody>
                </table>
            </div>
        </fieldset>
    </div>
	
</form>