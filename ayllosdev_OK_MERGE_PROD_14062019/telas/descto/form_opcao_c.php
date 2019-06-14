<?php
/* !
 * FONTE        : form_opcao_c.php
 * CRIACAO      : Rogerius Militao - (DB1)
 * DATA CRIACAO : 18/01/2012 
 * OBJETIVO     : Formulario que apresenta a consulta da opcao C da tela DESCTO
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
        
        <div class="consulta_data">
            <label for="dtlibini"><?php echo utf8ToHtml('Data Inicio:') ?></label>
            <input type="text" id="dtlibini" name="dtlibini" value="<?php echo $dtlibini ?>"/>

            <label for="dtlibfim">Data Final:</label>
            <input type="text" id="dtlibfim" name="dtlibfim" value="<?php echo $dtlibfim ?>"/>        
        </div>
        
    </fieldset>		


    <fieldset>
        <legend> Cheques </legend>

        <div class="divRegistros">	
            <table class="tituloRegistros">
                <thead>
                    <tr>
                        <th><?php echo utf8ToHtml('Liberar'); ?></th>
                        <th><?php echo utf8ToHtml('Bco'); ?></th>
                        <th><?php echo utf8ToHtml('Ag.'); ?></th>
                        <th><?php echo utf8ToHtml('Conta'); ?></th>
                        <th><?php echo utf8ToHtml('Cheque'); ?></th>
                        <th><?php echo utf8ToHtml('Valor'); ?></th>
                        <th><?php echo utf8ToHtml('Resg/Dev'); ?></th>
                        <th></th>
                        <th><?php echo utf8ToHtml('Operador'); ?></th>
                        <th><?php echo utf8ToHtml('Conta'); ?></th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($registro as $r) { ?>
                        <tr>
                            <td><span><?php echo dataParaTimestamp(getByTagName($r->tags, 'dtlibera')); ?></span>
                                <?php echo getByTagName($r->tags, 'dtlibera'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'cdbanchq'); ?></span>
                                <?php echo getByTagName($r->tags, 'cdbanchq'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'cdagechq'); ?></span>
                                <?php echo getByTagName($r->tags, 'cdagechq'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'nrctachq'); ?></span>
                                <?php echo mascara(getByTagName($r->tags, 'nrctachq'), '###.###.###.#'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'nrcheque'); ?></span>
                                <?php echo getByTagName($r->tags, 'nrcheque'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'vlcheque'); ?></span>
                                <?php echo formataMoeda(getByTagName($r->tags, 'vlcheque')); ?>
                            </td>
                            <td><span><?php echo dataParaTimestamp(getByTagName($r->tags, 'dtdevolu')); ?></span>
                                <?php echo getByTagName($r->tags, 'dtdevolu'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'situacao'); ?></span>
                                <?php echo getByTagName($r->tags, 'situacao'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'cdopedev'); ?></span>
                                <?php echo getByTagName($r->tags, 'cdopedev'); ?>
                            </td>
                            <td><span><?php echo getByTagName($r->tags, 'nrdconta'); ?></span>
                                <?php echo formataContaDV(getByTagName($r->tags, 'nrdconta')); ?>
                            </td>
                        </tr>
                    <?php } ?>	
                </tbody>
            </table>
        </div>
    </fieldset>

</form>

<div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>	
        <tr>
            <td>
                <?php

                //
                if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;

                // Se a paginação não está na primeira, exibe botão voltar
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
                ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <?php echo $qtregist; ?><?php
                }
                ?>
            </td>
            <td>
                <?php
                // Se a paginação não está na &uacute;ltima página, exibe botão proximo
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
<style type="text/css">
    div.consulta_data {
        display: none;
    }
</style>    
<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        controlaOperacao(<?php echo "'" . $operacao . "','" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });
    $('a.paginacaoProx').unbind('click').bind('click', function() {
        controlaOperacao(<?php echo "'" . $operacao . "','" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
    $('#divPesquisaRodape', '#divTela').formataRodapePesquisa();</script>

<div id="divBotoes" style="padding-bottom:10px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar();return false;">Voltar</a>
    <a href="#" class="botao" onclick="btnContinuar();return false;" >Prosseguir</a>
</div>


