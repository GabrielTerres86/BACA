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
                    $cdremessa = getByTagName($reg->tags,'CDREMESSA');
                    $nmremessa = getByTagName($reg->tags,'NMREMESSA');
                    $arrRemessa[$cdremessa] = $nmremessa;
                    echo '<option value="'.$cdremessa.'">'.$cdremessa.' - '.$nmremessa.'</option> ';
                }
            ?>
        </select>
        <a href="#" class="botao" id="btVoltar"  onClick="btnVoltar();return false;" style="text-align: right; float: none;">Voltar</a>
        <a href="#" class="botao" id="btProsseguir" onClick="mostraOpcaoR();" style="text-align: right; float: none;">Prosseguir</a>
	</div>

    <div id="divRemessa2" style="margin-top:20px; display:none; text-align: center;" >
        <label for="remessa">Remessa:</label>
        <input type="text" name="cdremessa" id="cdremessa" value="<?php echo $remessa; ?>" />
        <input type="text" name="nmremessa" id="nmremessa" value="<?php echo $arrRemessa[$remessa]?>" />

        <br style="clear:both" />
        <br style="clear:both" />

        <fieldset id="fsetFormularioInc" name="fsetFormularioInc" style="padding:0px; margin:0px;">
        <legend> Incluir hist&oacute;rico </legend>
            <table width="500" style="margin: 5px 0px 10px 10px;">
            <tr>
                <td>C&oacute;digo</td>
                <td>Descri&ccedil;&atilde;o</td>
                <td>Tipo</td>
                <td>Movimento</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td><input type="text" name="cdhistor" id="cdhistor" /> <a style="padding: 3px 0 0 3px;" href="#" onClick="mostraPesquisaHistor();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a></td>
                <td><input type="text" name="dshistor" id="dshistor" /></td>
                <td><input type="text" name="tphistor" id="tphistor" /></td>
                <td>
                    <select id="tpfluxo" name="tpfluxo">
                    <option value="E">Entrada</option>
                    <option value="S">Saída</option>
                    </select>
                </td>
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
                            <th width="100">C&oacute;digo</th>
                            <th>Descri&ccedil;&atilde;o</th>
                            <th width="90">Tipo</th>
                            <th width="90">Movimento</th>
                            <th width="90">Remover</th>
                        </tr>
                    </thead>
                    <tbody id="tbodyHistor">
                    <?php
                        foreach ($reghistor as $reg) {
                            $cdhistor = getByTagName($reg->tags,'CDHISTOR');
                            $dshistor = getByTagName($reg->tags,'DSHISTOR');
                            $tphistor = getByTagName($reg->tags,'TPHISTOR');
                            $tpfluxo  = getByTagName($reg->tags,'TPFLUXO');
                            $lnhistor = $remessa.'_'.$cdhistor.'_'.substr($tpfluxo, 0, 1);
                            echo '
                            <tr id="'.$lnhistor.'">
                                <td width="100">'.$cdhistor.'</td>
                                <td>'.$dshistor.'</td>
                                <td width="90">'.$tphistor.'</td>
                                <td width="90">'.$tpfluxo.'</td>
                                <td width="90"><img onclick="confirmaExclusao(\''.$lnhistor.'\');" style="cursor:hand;" src="../../imagens/geral/panel-error_16x16.gif" width="13" height="13" /></td>
                            </tr>';
                        }
                    ?>
                    </tbody>
                </table>
            </div>
        </fieldset>
    </div>
	
</form>