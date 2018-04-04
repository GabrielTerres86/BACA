<?php
/* !
 * FONTE        : form_opcao_c.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 08/03/2018
 * OBJETIVO     : Formulario que apresenta a consulta da opcao C da tela TITCTO
 * --------------
 * ALTERACOES   :
 * --------------
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

include('form_cabecalho.php');
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

    <fieldset>
        <legend> Associado </legend>	
        
        <label for="nrdconta">Conta:</label>
        <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
        <a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

        <label for="nrcpfcgc">CPF/CNPJ:</label>
        <input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo $nrcpfcgc ?>"/>

        <label for="nmprimtl">Titular:</label>
        <input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
        
        <div class="tipo_cobranca">
            <label for="tpcobran">Tipo de Cobran&ccedil;a</label>
            <select  id="tpcobran" name="tpcobran">
                <option value="T" <?php echo $tpcobran == 'T' ? 'selected' : '' ?>>Todos</option>
                <option value="R" <?php echo $tpcobran == 'R' ? 'selected' : '' ?>>Cobran&ccedil;a Registrada</option>
                <option value="S" <?php echo $tpcobran == 'S' ? 'selected' : '' ?>>Cobran&ccedil;a S/ Registro</option>
            </select>
        </div>
    </fieldset>		


    <fieldset>
        <legend> T&iacute;tulos </legend>

        <div class="divRegistros">	
            <table class="tituloRegistros">
                <thead>
                    <tr>
                        <th><?php echo utf8ToHtml('LIBERADO'); ?></th>
                        <th><?php echo utf8ToHtml('VENCTO'); ?></th>
                        <th><?php echo utf8ToHtml('CONVENIO'); ?></th>
                        <th><?php echo utf8ToHtml('TIPO COBR.'); ?></th>
                        <th><?php echo utf8ToHtml('BCO'); ?></th>
                        <th><?php echo utf8ToHtml('BOLETO'); ?></th>
                        <th><?php echo utf8ToHtml('BORDERO'); ?></th>
                        <th><?php echo utf8ToHtml('VALOR'); ?></th>
                        <th><?php echo utf8ToHtml('DESCTDO POR NOME'); ?></th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($registros as $r) { ?>
                        <tr>
                            <td><span><?php echo dataParaTimestamp(getByTagName($r->tags, 'dtlibbdt')); ?></span>
                                <?php echo getByTagName($r->tags, 'dtlibbdt'); ?>
                            </td>
                            <td><span><?php echo dataParaTimestamp(getByTagName($r->tags, 'dtvencto')); ?></span>
                                <?php echo getByTagName($r->tags, 'dtvencto'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'nrcnvcob'); ?></span>
                                <?php echo getByTagName($r->tags, 'nrcnvcob'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'tpcobran'); ?></span>
                                <?php echo getByTagName($r->tags, 'tpcobran'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'cdbandoc'); ?></span>
                                <?php echo getByTagName($r->tags, 'cdbandoc'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'nrdocmto'); ?></span>
                                <?php echo getByTagName($r->tags, 'nrdocmto'); ?>
                            </td>
                            <td><span><?php echo dataParaTimestamp(getByTagName($r->tags, 'nrborder')); ?></span>
                                <?php echo getByTagName($r->tags, 'nrborder'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'vltitulo'); ?></span>
                                <?php echo formataMoeda(getByTagName($r->tags, 'vltitulo')); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'nmprimt'); ?></span>
                                <?php echo trim(getByTagName($r->tags, 'nmprimt')); ?>
                            </td>
                        </tr>
                    <?php } ?>	
                </tbody>
            </table>
        </div>
    </fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar();return false;">Voltar</a>
    <a href="#" class="botao" onclick="btnContinuar();return false;" >Prosseguir</a>
</div>


