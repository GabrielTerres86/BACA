<?
/*!
 * FONTE        	: form_tab097.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Novembro/2015
 * OBJETIVO     	: Form para a tela TAB097
 * ÚLTIMA ALTERAÇÃO : 17/04/2019
 * --------------
 * ALTERAÇÕES   	: 17/04/2019 - Adicionado nova tabela referente a indexcecao 3 RITM0012246 (Mateus Z - Mouts)
 * --------------
 */

 $estados = retornaUFs();
?>

<form id="frmTab097" name="frmTab097" class="formulario" style="display:none; border-bottom: 1px solid #777777; ">
    <input name="hdnvalor" id="hdnvalor" type="hidden" />
	<input name="cdcooper" id="cdcooper" type="hidden" value="<? echo $glbvars["cdcooper"]; ?>" />
    <br />
    <table width="100%">
        <tr>
            <td width="50%">
                <label for="qtminimo_negativacao"><? echo utf8ToHtml('Prazo m&iacute;nimo de negativa&ccedil;&atilde;o:') ?></label>					
                <input name="qtminimo_negativacao" id="qtminimo_negativacao" type="text" />
            </td>
            <td width="50%">
                <label for="qtmaximo_negativacao"><? echo utf8ToHtml('Prazo m&aacute;ximo de negativa&ccedil;&atilde;o:') ?></label>
                <input name="qtmaximo_negativacao" id="qtmaximo_negativacao" type="text" />
            </td>
        </tr>
        <tr>
            <td>
                <label for="hrenvio_arquivo"><? echo utf8ToHtml('Hor&aacute;rio de envio do arquivo:') ?></label>
                <input name="hrenvio_arquivo" id="hrenvio_arquivo" type="text" />
            </td>
            <td>
                <label for="vlminimo_boleto"><? echo utf8ToHtml('Valor m&iacute;nimo do boleto:') ?></label>
                <input name="vlminimo_boleto" id="vlminimo_boleto" type="text" />
            </td>
        </tr>
        <tr>
            <td>
                <label for="qtdias_vencimento"><? echo utf8ToHtml('Dias para c&aacute;lculo do vencimento:') ?></label>
                <input name="qtdias_vencimento" id="qtdias_vencimento" type="text" />
            </td>
            <td>
                <label for="qtdias_negativacao"><? echo utf8ToHtml('Dias para neg. ap&oacute;s ret. Serasa:') ?></label>
                <input name="qtdias_negativacao" id="qtdias_negativacao" type="text" />
            </td>
        </tr>
    </table>
																				
	<div id="divMsgAjuda" style="margin-top:5px; margin-bottom :20px; margin-right: 47px; display:none; text-align: center; height:30px;" >
		<a href="#" class="botao" id="btVoltar"  onClick="btnVoltar();return false;" style="text-align: right; float: none;">Voltar</a>
		<a href="#" class="botao" id="btAlterar" onClick="alterarDados();" style="text-align: right; float: none;">Alterar</a>
	</div>

	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('CNAEs n&atilde;o Habilitados para o Servi&ccedil;o'); ?> </legend>
        <?php
            // Somente CECRED podera utilizar acao
            if ($glbvars["cdcooper"] == 3) {
                ?>
                <table width="100%" id="tabAcao">
                    <tr>
                        <td>
                            <label for="acao_cnae"><? echo utf8ToHtml('A&ccedil;&atilde;o:') ?></label>					
                            <select id="acao_cnae" name="acao_cnae">
                                <option value="I"> Incluir</option> 
                                <option value="E"> Excluir</option>
                            </select>
                            <a href="#" class="botao" id="btnOKCNAE" onClick="executarAcao('CNAE');return false;" style="text-align: right;">OK</a>
                        </td>
                    </tr>
                </table>
                <?php
            }
        ?>
        
        <div id="divCNAE" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
                        <th><?php echo utf8ToHtml('C&oacute;digo') ?></th>
						<th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o') ?></th>
					</tr>
				</thead>
				<tbody>
				<?php
                    foreach( $registros as $r ) {
                        $cdcnae = getByTagName($r->tags,'cdcnae');
                        $dscnae = strtoupper(getByTagName($r->tags,'dscnae'));
                        ?>
                        <tr>
                            <td>
                                <img class="clsExcCNAE" onclick="confirmaExclusao('CNAE','<?php echo $cdcnae ?>');" src="<?php echo $UrlImagens; ?>geral/panel-error_16x16.gif" style="width:10px; height:10px; margin-top:3px; margin-right:3px;" />
                                <?php echo $cdcnae ?>
                            </td>
                            <td><?php echo $dscnae ?></td>
                        </tr>
                        <?php
                    }
				?>
				</tbody>
			</table>
		</div>
    
        <div id="divPesquisaRodape" class="divPesquisaRodape">
          <table>	
            <tr>
              <td>
                <?php
                if (isset($qtregist) and $qtregist == 0) {
                  $nriniseq = 0;
                }
                  // Se a paginacao nao esta na primeira, exibe botao voltar
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
                  ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php
                  if (($nriniseq + $nrregist) > $qtregist) {
                    echo $qtregist;
                  } else {
                    echo ($nriniseq + $nrregist - 1);
                  }
                  ?> de <?php echo $qtregist; ?><?php
                }
                ?>
              </td>
              <td>
                <?php
                // Se a paginacao nao esta na ultima pagina, exibe botao proximo
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

	</fieldset>

    <br />

	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('UFs com AR'); ?> </legend>
        <?php
            // Somente CECRED podera utilizar acao
            if ($glbvars["cdcooper"] == 3) {
                ?>
                <table width="100%" id="tabAcaoUF">
                    <tr>
                        <td>
                            <label for="acao_uf"><? echo utf8ToHtml('A&ccedil;&atilde;o:') ?></label>					
                            <select id="acao_uf" name="acao_uf">
                                <option value="I"> Incluir</option> 
                                <option value="E"> Excluir</option>
                            </select>
                            <a href="#" class="botao" id="btnOKCNAEUF" onClick="executarAcao('UF');return false;" style="text-align: right;">OK</a>
                        </td>
                    </tr>
                </table>
                <?php
            }
        ?>
        
        <div id="divUF" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
                        <th><?php echo utf8ToHtml('UF') ?></th>
						<th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o') ?></th>
					</tr>
				</thead>
				<tbody>
				<?php
                    foreach( $param_uf as $r ) {
                        $dsuf = $r->cdata;
						$key  = retornaKeyArrayMultidimensional($estados,'SIGLA',$dsuf);
                        $nmuf = mb_strtoupper(html_entity_decode($estados[$key]['NOME']));
						$indexcecao = getByTagName($r->tags,'indexcecao');
                        ?>
                        <tr>
                            <td>
                                <img class="clsExcUF" onclick="confirmaExclusao('UF','1|<?php echo $dsuf ?>');" src="<?php echo $UrlImagens; ?>geral/panel-error_16x16.gif" style="width:10px; height:10px; margin-top:3px; margin-right:3px;" />
                                <?php echo $dsuf ?>
                            </td>
                            <td><?php echo $nmuf ?></td>
                        </tr>
                        <?php
                    }
				?>
				</tbody>
			</table>
		</div>

	</fieldset>

    <br />

	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('UFs com prazo de negativa&ccedil;&atilde;o diferenciado'); ?> </legend>
        <?php
            // Somente CECRED podera utilizar acao
            if ($glbvars["cdcooper"] == 3) {
                ?>
                <table width="100%" id="tabAcaoUFNegDif">
                    <tr>
                        <td>
                            <label for="acao_uf_neg_dif"><? echo utf8ToHtml('A&ccedil;&atilde;o:') ?></label>					
                            <select id="acao_uf_neg_dif" name="acao_uf_neg_dif">
                                <option value="I"> Incluir</option>
								<option value="ALT"> Alterar</option>
                                <option value="E"> Excluir</option>
                            </select>
                            <a href="#" class="botao" id="btnOKCNAEUF" onClick="executarAcao('UFNegDif');return false;" style="text-align: right;">OK</a>
                        </td>
                    </tr>
                </table>
                <?php
            }
        ?>
        
        <div id="divUFNegDif" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
                        <th><?php echo utf8ToHtml('UF') ?></th>
						<th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o') ?></th>
                        <th><?php echo utf8ToHtml('Prazo') ?></th>
					</tr>
				</thead>
				<tbody>
				<?php
                    foreach( $param_ufnegdif as $r ) {
                        $qtminimo_negativacao2 = getByTagName($r->tags,'qtminimo_negativacao');
						$dsuf = getByTagName($r->tags,'dsuf');
						$key  = retornaKeyArrayMultidimensional($estados,'SIGLA',$dsuf);
                        $nmuf = mb_strtoupper(html_entity_decode($estados[$key]['NOME']));
						$indexcecao = getByTagName($r->tags,'indexcecao');
                        ?>
                        <tr>
                            <td>
                                <img class="clsExcUFNegDif" onclick="confirmaExclusao('UF','2|<?php echo $dsuf ?>');" src="<?php echo $UrlImagens; ?>geral/panel-error_16x16.gif" style="width:10px; height:10px; margin-top:3px; margin-right:3px;" />
								<img class="clsAltUFNegDif" onclick="abreTelAlteracao('2|<?php echo $dsuf ?>');" src="<?php echo $UrlImagens; ?>geral/servico_ativo.gif" style="width:13px; height:13px; margin-top:3px; margin-right:3px;" />
                                <?php echo $dsuf ?>
                            </td>
                            <td><?php echo $nmuf ?></td>
							<td><?php echo $qtminimo_negativacao2 ?></td>
                        </tr>
                        <?php
                    }
				?>
				</tbody>
			</table>
		</div>

	</fieldset>

    <br />

    <fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
    <legend> <? echo utf8ToHtml('UFs com prazo para negativa&ccedil;&atilde;o ap&oacute;s retorno Serasa'); ?> </legend>
        <?php
            // Somente CECRED podera utilizar acao
            if ($glbvars["cdcooper"] == 3) {
                ?>
                <table width="100%" id="tabAcaoUFNegRec">
                    <tr>
                        <td>
                            <label for="acao_uf_neg_rec"><? echo utf8ToHtml('A&ccedil;&atilde;o:') ?></label>                   
                            <select id="acao_uf_neg_rec" name="acao_uf_neg_rec">
                                <option value="I"> Incluir</option>
                                <option value="ALT"> Alterar</option>
                                <option value="E"> Excluir</option>
                            </select>
                            <a href="#" class="botao" id="btnOKCNAEUF" onClick="executarAcao('UFNegRec');return false;" style="text-align: right;">OK</a>
                        </td>
                    </tr>
                </table>
                <?php
            }
        ?>
        
        <div id="divUFNegRec" class="divRegistros">
            <table width="100%">
                <thead>
                    <tr>
                        <th><?php echo utf8ToHtml('UF') ?></th>
                        <th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o') ?></th>
                        <th><?php echo utf8ToHtml('Prazo') ?></th>
                    </tr>
                </thead>
                <tbody>
                <?php
                    foreach( $param_ufnegrec as $r ) {
                        $qtminimo_negativacao2 = getByTagName($r->tags,'qtminimo_negativacao');
                        $dsuf = getByTagName($r->tags,'dsuf');
                        $key  = retornaKeyArrayMultidimensional($estados,'SIGLA',$dsuf);
                        $nmuf = mb_strtoupper(html_entity_decode($estados[$key]['NOME']));
                        $indexcecao = getByTagName($r->tags,'indexcecao');
                        ?>
                        <tr>
                            <td>
                                <img class="clsExcUFNegRec" onclick="confirmaExclusao('UF','3|<?php echo $dsuf ?>');" src="<?php echo $UrlImagens; ?>geral/panel-error_16x16.gif" style="width:10px; height:10px; margin-top:3px; margin-right:3px;" />
                                <img class="clsAltUFNegRec" onclick="abreTelAlteracao('3|<?php echo $dsuf ?>');" src="<?php echo $UrlImagens; ?>geral/servico_ativo.gif" style="width:13px; height:13px; margin-top:3px; margin-right:3px;" />
                                <?php echo $dsuf ?>
                            </td>
                            <td><?php echo $nmuf ?></td>
							<td><?php echo $qtminimo_negativacao2 ?></td>
                        </tr>
                        <?php
                    }
				?>
				</tbody>
			</table>
		</div>

	</fieldset>

	<br style="clear:both" />	
	
</form>

<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        controlaOperacao('<?php echo ($nriniseq - $nrregist); ?>','<?php echo $nrregist; ?>');
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        controlaOperacao('<?php echo ($nriniseq + $nrregist); ?>','<?php echo $nrregist; ?>');
    });

</script>