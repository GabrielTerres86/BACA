<?php
/* !
 * FONTE        : grid_menu.php
 * CRIAÇÃO      : Ricardo Linhares
 * DATA CRIAÇÃO : 30/01/2017
 * OBJETIVO     : Grid dos Menus IB
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<fieldset>

    <legend><?php echo utf8ToHtml('Pacotes cadastrados') ?></legend>

    <div id="divPacotes">
        <div class="divRegistros">	
            <table>
                <thead>
                    <tr>
                        <th><?php echo utf8ToHtml('Código'); ?></th>
                        <th><?php echo utf8ToHtml('Descrição'); ?></th>
                        <th><?php echo utf8ToHtml('Situação'); ?></th>
                        <th><?php echo utf8ToHtml('Valor'); ?></th>
                    </tr>
                </thead>
                <tbody>

                    <?php foreach ($registros as $r) { ?>

                        <? $qtregist = getByTagName($r->tags, 'qtregist')  ?>

                        <tr id="<?php echo getByTagName($r->tags, 'idpacote') ?>" >
                            <td>
                                <?php echo getByTagName($r->tags, 'idpacote') ?>
                            </td>
                            <td>
                                <?php echo getByTagName($r->tags, 'dspacote') ?>
                            </td>
                            <td>
                                <?php echo getByTagName($r->tags, 'flgstatus') ?>
                            </td>
                            <td>
                                <?php echo getByTagName($r->tags, 'vlpacote') ?>
                            </td>
                        </tr>
                    <?php } ?>	
                </tbody>
            </table>
        </div>	


    <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>	
            <tr>
                <td>
                    <?			
                        if (isset($qtregist) and $qtregist == 0) $pagina = 0;
                        
                        // Se a paginação não está na primeira, exibe botão voltar
                        if ($pagina > 1) { 
                            ?> <a class='paginacaoAnt'><<< Anterior</a> <? 
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
                <td>
                    <?
                        if (isset($pagina) && $pagina > 0 && $qtregist > 0) { 
                            ?> Exibindo <? 
                                  echo ($pagina * $tamanho_pagina) - ($tamanho_pagina - 1); ?> 
                                at&eacute; <? 

                                if($pagina == 1) {
                                    if ($qtregist > $tamanho_pagina) {
                                        echo $tamanho_pagina;
                                    } else {
                                        echo $qtregist;
                                    }

                                } else if (($pagina * $tamanho_pagina) > $qtregist) { 
                                    echo $qtregist; 
                                } else { 
                                    echo (($pagina * $tamanho_pagina) - ($tamanho_pagina) + $tamanho_pagina); 
                                } ?> 
                                de <? echo $qtregist; ?>
                    <?
                        }
                    ?>
                </td>
                <td>
                    <?
                        // Se a paginação não está na &uacute;ltima página, exibe botão proximo
                        if ($qtregist > ($pagina * $tamanho_pagina - 1) && $pagina > 0) {
                            ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>			
                </td>
            </tr>
        </table>
</div>


</div>

</fieldset>

	<br style="clear:both" />

    <div id="divBotoes" style="margin-bottom: 10px;">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial();">Voltar</a>	
		<a href="#" class="botao" id="btDetalhar" onClick="Grid.onClick_Detalhar();">Detalhar</a>	
        <a href="#" class="botao" id="btAlterar" onClick="Grid.onClick_Detalhar();">Alterar</a>	
	</div>


<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		Grid.carregar(<? echo "'".$cdcooper."','".$flgstatus."','".($pagina - 1)."','".$tamanho_pagina."'"; ?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		Grid.carregar(<? echo "'".$cdcooper."','".$flgstatus."','".($pagina + 1)."','".$tamanho_pagina."'"; ?>);
	});	

	$('#divPesquisaRodape').formataRodapePesquisa();

</script> 