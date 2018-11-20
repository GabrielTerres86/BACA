<?php
/*!
 * FONTE        : tab_pendencias.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : Junho/2016
 * OBJETIVO     : Tabela de Seguros Pendentes Sicredi
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [06/11/2018] Adicionado campos no formulário para selecionar os itens da lsita para "deleta-los". ( Christian Grauppe/ENVOLTI )
 * 001: [08/11/2018] Adicionado campos para busca e filtro da lista por CPF/CNPJ e Nr. de Apólice. ( Christian Grauppe/ENVOLTI )
 */
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<fieldset>
		<legend> <? echo utf8ToHtml('Filtro de Busca:');  ?> </legend>

		<label for="nrapolice" class="txtNormalBold rotulo" style="width:150px;"><?php echo utf8ToHtml('Apólice'); ?>:</label>
		<input name="nrapolice" type="text" id="nrapolice" class="inteiro campo" value="" />

		<label for="nrcpfcnj" class="txtNormalBold rotulo-linha" style="width:150px;">CPF/CNPJ:</label>
		<input name="nrcpfcnj" type="text" id="nrcpfcnj" class="inteiro campo" value="" />

		<a href="#" class="botao" onclick="btnBuscaSegurosFiltro(); return false;" style="margin-left:30px;" >Buscar</a>

		<br style="clear:both" />

		<input type="hidden" name="nrregist" id="nrregist" value="<?php echo $nrregist; ?>" />
	</fieldset>

	<br style="clear:both" />

</form>

<div id="tabPendencias" style="display:block">
    <div class="divRegistros">
        <table class="tituloRegistros">
            <thead>
                <tr>
                    <th> <input type="checkbox" id="iptdeltodos" name="iptdeltodos" value="todos" /> </th>
                    <th><?php echo utf8ToHtml('Data de Importa&ccedil;&atilde;o');  ?></th>
                    <th><?php echo utf8ToHtml('Proposta');  ?></th>
                    <th><?php echo utf8ToHtml('Ap&oacute;lice');  ?></th>
                    <th><?php echo utf8ToHtml('Endosso');  ?></th>
                    <th><?php echo utf8ToHtml('CPF/CNPJ');  ?></th>
                    <th><?php echo utf8ToHtml('Situa&ccedil;&atilde;o');  ?></th>
                </tr>
            </thead>
            <tbody>
                <?php
                if ( count($pendencias) == 0 ) {
                    $i = 0;
                    // Monta uma coluna mesclada com a quantidade de colunas que seria exibida
                    ?> <tr>
                            <td colspan="12" style="width: 80px; text-align: center;">
                                <input type="hidden" id="conteudo" name="conteudo" value="<?php echo $i; ?>" />
                                <b>N&atilde;o foram encontrados seguros pendentes de ajuste.</b>
                            </td>
                        </tr>
                <?php  // Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
                } else {
                    for ($i = 0; $i < count($pendencias); $i++) {
                    ?>
                        <tr>
							<td><input style="cursor:pointer;" type="checkbox" class="iptdel" name="iptdel[<?php echo $i; ?>]" value="<?php echo getByTagName($pendencias[$i]->tags,'idcontrato'); ?>" /></td>
                            <td><input type="hidden" id="conteudo"            name="conteudo"            value="<?php echo 1; ?>" />
                                <input type="hidden" id="idcontrato"          name="idcontrato"          value="<?php echo getByTagName($pendencias[$i]->tags,'idcontrato') ?>" />
                                <input type="hidden" id="dtmvtolt"            name="dtmvtolt"            value="<?php echo getByTagName($pendencias[$i]->tags,'dtmvtolt') ?>" />
                                <input type="hidden" id="nrproposta"          name="nrproposta"          value="<?php echo getByTagName($pendencias[$i]->tags,'nrproposta') ?>" />
                                <input type="hidden" id="nrapolice"           name="nrapolice"           value="<?php echo getByTagName($pendencias[$i]->tags,'nrapolice') ?>" />
                                <input type="hidden" id="nrendosso"           name="nrendosso"           value="<?php echo getByTagName($pendencias[$i]->tags,'nrendosso') ?>" />
                                <input type="hidden" id="indsituacao"         name="indsituacao"         value="<?php echo utf8ToHtml(getByTagName($pendencias[$i]->tags,'indsituacao')) ?>" />
                                <input type="hidden" id="dtinicio_vigencia"   name="dtinicio_vigencia"   value="<?php echo getByTagName($pendencias[$i]->tags,'dtinicio_vigencia') ?>" />
                                <input type="hidden" id="dttermino_vigencia"  name="dttermino_vigencia"  value="<?php echo getByTagName($pendencias[$i]->tags,'dttermino_vigencia') ?>" />
                                <input type="hidden" id="nmsegura"            name="nmsegura"            value="<?php echo getByTagName($pendencias[$i]->tags,'nmsegura') ?>" />
                                <input type="hidden" id="nmmarca"             name="nmmarca"             value="<?php echo utf8ToHtml(getByTagName($pendencias[$i]->tags,'nmmarca')) ?>" />
                                <input type="hidden" id="dsmodelo"            name="dsmodelo"            value="<?php echo utf8ToHtml(getByTagName($pendencias[$i]->tags,'dsmodelo')) ?>" />
                                <input type="hidden" id="dschassi"            name="dschassi"            value="<?php echo getByTagName($pendencias[$i]->tags,'dschassi') ?>" />
                                <input type="hidden" id="dsplaca"             name="dsplaca"             value="<?php echo getByTagName($pendencias[$i]->tags,'dsplaca') ?>" />
                                <input type="hidden" id="nrano_fabrica"       name="nrano_fabrica"       value="<?php echo getByTagName($pendencias[$i]->tags,'nrano_fabrica') ?>" />
                                <input type="hidden" id="nrano_modelo"        name="nrano_modelo"        value="<?php echo getByTagName($pendencias[$i]->tags,'nrano_modelo') ?>" />
                                <input type="hidden" id="nrcpf_cnpj_segurado" name="nrcpf_cnpj_segurado" value="<?php echo getByTagName($pendencias[$i]->tags,'nrcpf_cnpj_segurado') ?>" />
								<input type="hidden" id="nmdosegurado"        name="nmdosegurado"        value="<?php echo getByTagName($pendencias[$i]->tags,'nmsegurado') ?>" />
								<input type="hidden" id="dsdocpfcnpj"         name="dsdocpfcnpj"         value="<?php echo getByTagName($pendencias[$i]->tags,'dsdocpfcnpj') ?>" />
                                <input type="hidden" id="cdcooper"            name="cdcooper"            value="<?php echo getByTagName($pendencias[$i]->tags,'cdcooper') ?>" />
                                <input type="hidden" id="nrdconta"            name="nrdconta"            value="<?php echo getByTagName($pendencias[$i]->tags,'nrdconta') ?>" />
                                <input type="hidden" id="imgSitCoop"          name="imgSitCoop"          value="<?php echo getByTagName($pendencias[$i]->tags,'imgSitCoop') ?>" />
                                <span><?php echo getByTagName($pendencias[$i]->tags,'dtmvtolt'); ?></span>
                                      <?php echo getByTagName($pendencias[$i]->tags,'dtmvtolt'); ?>
                            </td>
                            <td><span><?php echo getByTagName($pendencias[$i]->tags,'nrproposta'); ?></span>
                                      <?php echo getByTagName($pendencias[$i]->tags,'nrproposta'); ?>
                            </td>
                            <td><span><?php echo getByTagName($pendencias[$i]->tags,'nrapolice'); ?></span>
                                      <?php echo getByTagName($pendencias[$i]->tags,'nrapolice'); ?>
                            </td>
                            <td><span><?php echo getByTagName($pendencias[$i]->tags,'nrendosso'); ?></span>
                                      <?php echo getByTagName($pendencias[$i]->tags,'nrendosso'); ?>
                            </td>
                            <td><span><?php echo getByTagName($pendencias[$i]->tags,'nrcpf_cnpj_segurado'); ?></span>
                                      <?php echo getByTagName($pendencias[$i]->tags,'nrcpf_cnpj_segurado'); ?>
                            </td>
                            <td><span><?php echo getByTagName($pendencias[$i]->tags,'indsituacao'); ?></span>
                                      <?php echo getByTagName($pendencias[$i]->tags,'indsituacao'); ?>
                            </td>
                        </tr>
                    <?php } ?>
            <?php } ?>
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
                    ?> <a class='paginacaoAnterior'><<< Anterior</a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>
            </td>
            <td>
                <?php
                if (isset($nriniseq)) {
                    ?> Exibindo <span id="nriniseq" style="font-size:10px;"><?php echo $nriniseq; ?></span> at&eacute; <?php
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
                    ?> <a class='paginacaoProximo'>Pr&oacute;ximo >>></a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>			
            </td>
        </tr>
    </table>
</div>

<script type="text/javascript">

	var nrcpfcnj, nrapolice;

    $('a.paginacaoAnterior').unbind('click').bind('click', function() {
        buscaSegurosPendentes(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        buscaSegurosPendentes(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('#divPesquisaRodape','#divTela').formataRodapePesquisa();

    $(".iptdel").click(function () {
        if ($(this).is(":checked")) {
            var isAllChecked = 0;

            $(".iptdel").each(function() {
                if (!this.checked)
                    isAllChecked = 1;
            });

            if (isAllChecked == 0) {
                $("#iptdeltodos").prop("checked", true);
            }
        } else {
            $("#iptdeltodos").prop("checked", false);
        }
    });

	if (typeof nrapolice !== "undefined") {
		$("#nrapolice").val(nrapolice);
	}
	if (typeof nrcpfcnj !== "undefined") {
		$("#nrcpfcnj").val(nrcpfcnj);
	}
	nriniseq = $("span#nriniseq").text();
	nrregist = <?php echo "'" . $nrregist . "'"; ?>;

	$("#nrapolice").keyup(function(){
		valor = $(this).val();
		valor=valor.replace(/\D/g,"");
		$(this).val(valor);
	});
	$("#nrcpfcnj").keyup(function(){
		valor = $(this).val();
		valor=valor.replace(/\D/g,"");
		$(this).val(valor);
	});

</script>