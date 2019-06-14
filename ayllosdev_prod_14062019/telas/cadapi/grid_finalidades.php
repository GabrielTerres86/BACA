<div class="divRegistros" style="height:188px">
	<table class="tituloRegistros">
		<thead>
			<tr><th>&nbsp;</th>
				<th>Descri&ccedil;&atilde;o</th>
			</tr>
		</thead>
		<tbody>
			<?php
			
            foreach ($registros as $r) {
                $cdfinalidade  = getByTagName($r->tags,"cdfinalidade");
                $dsfinalidade  = getByTagName($r->tags,"dsfinalidade");
                $idsituacao    = getByTagName($r->tags,"idsituacao");
				
				?>
				<tr id="linha_<? echo $cdfinalidade; ?>">
					<td width="25">
						<input type="hidden" id="cdfinalidade" name="cdfinalidade" value="<?php echo $cdfinalidade; ?>" />
						<input type="hidden" id="dsfinalidade" name="dsfinalidade" value="<?php echo $dsfinalidade; ?>" />
						<input type="checkbox" id="idsituacao" value="<?php echo $cdfinalidade; ?>" <?php echo $idsituacao ? 'checked' : '';?> <?php echo in_array($cddopcao, array('C','E')) ? 'readonly disabled' : '';?> />
					</td>
					<td><?php echo $dsfinalidade; ?></td>
				</tr>
				<?php
            }
            if ($arr_dsfinalidade && $carregarFinalidades == 0) {
                $items = explode('|', $arr_dsfinalidade);
                foreach ($items as $item) {
                $finalidade = explode('#', $item);
            ?>
                <tr id="new_<? if ($finalidade[0]>0){ echo $finalidade[0]; }else{echo "0";}?>"<? if ($finalidade[0]==0){?> class="unsaved"<?}?>>
					<td width="25">
						<input type="hidden" id="cdfinalidade" name="cdfinalidade" value="<? if ($finalidade[0]>0){ echo $finalidade[0]; }?>" />
						<input type="hidden" id="dsfinalidade" name="dsfinalidade" value="<?php echo utf8_decode($finalidade[1]); ?>" />
						<input type="checkbox" id="idsituacao" value="" <?php echo $finalidade[2] ? 'checked' : '';?> />
					</td>
					<td><?php echo utf8_decode($finalidade[1]); ?></td>
				</tr>
            <?
                }
            }
            ?>
		</tbody>
	</table>
</div>
<div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>	
        <tr>
            <td>&nbsp;</td>
            <td>
                <?
					$qtregist = count($registros);
					$pagina = 1;
					$tamanho_pagina = $qtregist;
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
            <td>&nbsp;</td>
        </tr>
    </table>
</div>

<?php if ($cddopcao != 'C') { ?>
<div id="divBotoesAcoes" style="margin-bottom: 10px;padding-top: 10px;display: block;clear: both;float: none;text-align: center;">
	<?php if ($cddopcao == 'F') { ?>
	<a href="#" class="botao" id="btAdicionar" onclick="popup.exibir(false); return false;">Adicionar</a>
    <a href="#" class="botao" id="btAlterar" onclick="popup.exibir(true); return false;">Alterar</a>
	<?php } elseif ($cddopcao == 'E') { ?>
    <a href="#" class="botao" id="btRemover" onclick="grid.onClick_Remover(); return false;">Remover</a>
	<?php } ?>
</div>
<?php } ?>

<br style="clear:both" />

<hr style="background-color:#666; height:1px;" />

<div id="divBotoes" style="margin-bottom: 10px;">
    <a href="#" class="botao" id="btVoltar" onClick="estadoInicial();">Voltar</a>
	<?php if ($cddopcao != 'C') { ?>
    <a href="#" class="botao" id="btProsseguir" onClick="grid.onClick_Gravar();">Gravar</a>
	<?php } ?>
</div>
<script>
	hideMsgAguardo();
</script>