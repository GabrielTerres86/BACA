<?
/*!
 * FONTE        	: form_parprt.php
 * CRIAÇÃO      	: Andre Clemer
 * DATA CRIAÇÃO 	: Janeiro/2018
 * OBJETIVO     	: Form para a tela PARPRT
 * ÚLTIMA ALTERAÇÃO : 08/10/2018
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 * 
 *  08/10/2018 - Inclusao de parametro dsnegufds referente às UFs não autorizadas 
                 a protestar boletos com DS. (projeto "PRJ352 - Protesto" - 
                 Marcelo R. Kestring - Supero)
 */

 $estados = retornaUFs();
?>

<form id="frmParPrt" name="frmParPrt" class="formulario" style="display:none; border-bottom: 1px solid #777777; ">
    <input name="hdnvalor" id="hdnvalor" type="hidden" />
	<input name="cdcooper" id="cdcooper" type="hidden" value="<? echo $glbvars["cdcooper"]; ?>" />
	<input name="cnaes" id="cnaes" type="hidden" value="" />
	<input name="ufs" id="ufs" type="hidden" value="" />
	<input name="negufds" id="negufds" type="hidden" value="" />
    <br />
    <table width="100%">
        <?php if ($cdcooper == 3) { ?>
        <tr>
            <td>
                <label for="hrenvio_arquivo"><? echo utf8ToHtml('Hor&aacute;rio de envio do arquivo:') ?></label>
                <input name="hrenvio_arquivo" id="hrenvio_arquivo" type="text" />
            </td>
            <td>
                &nbsp;
            </td>
        </tr>
        <?php } else { ?>
        <tr>
            <td width="50%">
                <label for="qtlimitemin_tolerancia"><? echo utf8ToHtml('Limite toler&acirc;ncia m&iacute;nimo:') ?></label>					
                <input name="qtlimitemin_tolerancia" id="qtlimitemin_tolerancia" type="text" />
            </td>
            <td width="50%">
                <label for="qtlimitemax_tolerancia"><? echo utf8ToHtml('Limite toler&acirc;ncia m&aacute;xima:') ?></label>
                <input name="qtlimitemax_tolerancia" id="qtlimitemax_tolerancia" type="text" />
            </td>
        </tr>
        <tr>
            <td>
                <label for="flcancelamento"><? echo utf8ToHtml('Permite cancelamento protesto:') ?></label>
                <select id="flcancelamento" name="flcancelamento">	
                    <option value="0" selected > N&atilde;o </option>				
                    <option value="1" > Sim </option>		
                </select>
            </td>
            <td>
                <label for="qtdias_cancelamento"><? echo utf8ToHtml('Dias para coop. solicitar cancelamento:') ?></label>
                <input name="qtdias_cancelamento" id="qtdias_cancelamento" type="text" />
            </td>
        </tr>
        
        <tr>
            <td>
                <input name="hrenvio_arquivo" id="hrenvio_arquivo" type="hidden" />
            </td>
        </tr>
        <?php } ?>
    </table>
																				
	<div id="divMsgAjuda" style="margin-top:5px; margin-bottom :20px; margin-right: 47px; display:none; text-align: center; height:30px;" >
		<a href="#" class="botao" id="btVoltar"  onClick="btnVoltar();return false;" style="text-align: right; float: none;">Voltar</a>
		<a href="#" class="botao" id="btAlterar" onClick="alterarDados();" style="text-align: right; float: none;">Alterar</a>
	</div>

    <?php if ($cddopcao == 'C' || ($cddopcao == 'A' && $cdcooper == 3)) { ?>

	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('CNAEs n&atilde;o habilitados para protesto'); ?> </legend>
        <?php
            // Somente CECRED podera utilizar acao
            // if ($glbvars["cdcooper"] == 3) {
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
            // }
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
                    foreach( $cdscnaes as $r ) {
                        $cnae = explode('|', $r);
                        $cdcnae = $cnae[0];
                        $dscnae = $cnae[1];
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
	</fieldset>

    <br />

	<fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('UFs autorizados para exclus&atilde;o eletr&ocirc;nica de protestos'); ?> </legend>
        <?php
            // Somente CECRED podera utilizar acao
            // if ($glbvars["cdcooper"] == 3) {
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
            // }
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
						$key  = retornaKeyArrayMultidimensional($estados,'SIGLA',$r);
                        $nmuf = mb_strtoupper(html_entity_decode($estados[$key]['NOME']));
                        ?>
                        <tr>
                            <td>
                                <img class="clsExcUF" onclick="confirmaExclusao('UF','<?php echo $r ?>');" src="<?php echo $UrlImagens; ?>geral/panel-error_16x16.gif" style="width:10px; height:10px; margin-top:3px; margin-right:3px;" />
                                <?php echo $r ?>
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
	<legend> <? echo utf8ToHtml('UFs autorizadas para n&atilde;o permitir emiss&atilde;o de boletos com DS - Duplicata de Servi&ccedil;o'); ?> </legend>
        <?php
            // Somente CECRED podera utilizar acao
            // if ($glbvars["cdcooper"] == 3) {
                ?>
                <table width="100%" id="tabAcaoNegUFDS">
                    <tr>
                        <td>
                            <label for="acao_negUFDS"><? echo utf8ToHtml('A&ccedil;&atilde;o:') ?></label>					
                            <select id="acao_negUFDS" name="acao_negUFDS">
                                <option value="I"> Incluir</option> 
                                <option value="E"> Excluir</option>
                            </select>
                            <a href="#" class="botao" id="btnOKNegUFDS" onClick="executarAcao('NEGUFDS');return false;" style="text-align: right;">OK</a>
                        </td>
                    </tr>
                </table>
                <?php
            // }
        ?>
        
        <div id="divNegUFDS" class="divRegistros">
			<table width="100%">
				<thead>
					<tr>
                        <th><?php echo utf8ToHtml('UF') ?></th>
						<th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o') ?></th>
					</tr>
				</thead>
				<tbody>
				<?php
                    foreach( $param_negufds as $r ) {
						$key  = retornaKeyArrayMultidimensional($estados,'SIGLA',$r);
                        $nmuf = mb_strtoupper(html_entity_decode($estados[$key]['NOME']));
                        ?>
                        <tr>
                            <td>
                                <img class="clsExcNegUFDS" onclick="confirmaExclusao('NEGUFDS','<?php echo $r ?>');" src="<?php echo $UrlImagens; ?>geral/panel-error_16x16.gif" style="width:10px; height:10px; margin-top:3px; margin-right:3px;" />
                                <?php echo $r ?>
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

    <?php } ?>

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