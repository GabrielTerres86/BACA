<?php
 /*!
 * FONTE        : form_autonovo.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : 15/06/2016
 * OBJETIVO     : Formulário da rotina Seguro da tela ATENDA
                  para SEGURO AUTO NOVO (SICREDI)
 */
 ?>

<form name="frmAutoNovo" id="frmAutoNovo" class="formulario">
    <br style="clear:both" />

    <label for="nmsegurado"><?php echo utf8ToHtml('Segurado:') ?></label>
    <input id="nmsegurado" name="nmsegurado" type="text" value="<?php echo $nmsegurado; ?>" />

    <label for="tpdoseguro"><?php echo utf8ToHtml('Tipo do Seguro:') ?></label>
    <input id="tpdoseguro" name="tpdoseguro" type="text" value="AUTOM&Oacute;VEL" />

    <fieldset style="width:95%;" >
        <legend align="left"><?php echo 'Dados do Seguro' ?></legend>

        <input type="hidden" id="idcontrato" name="idcontrato" value="<?php echo $idcontrato; ?>" />

        <label for="nmsegura"><?php echo utf8ToHtml('Seguradora:') ?></label>
        <input id="nmsegura" name="nmsegura" type="text" value="<?php echo $nmsegura; ?>" />
        <br style="clear:both" />

        <label for="dtinivig"><?php echo utf8ToHtml('In&iacute;cio da Vig&ecirc;ncia:') ?></label>
        <input id="dtinivig" name="dtinivig" type="text" value="<?php echo $Dtinivig; ?>" />
        <label for="dtfimvig"><?php echo utf8ToHtml('Final da Vig&ecirc;ncia:') ?></label>
        <input id="dtfimvig" name="dtfimvig" type="text" value="<?php echo $Dtfimvig; ?>" />
        <br style="clear:both" />


        <label for="nrproposta"><?php echo utf8ToHtml('Nr. Proposta:') ?></label>
        <input id="nrproposta" name="nrproposta" type="text" value="<?php echo $Nrproposta; ?>" />
        <label for="nrapolice"><?php echo utf8ToHtml('Nr. Ap&oacute;lice:') ?></label>
        <input id="nrapolice" name="nrapolice" type="text" value="<?php echo $Nrapolice; ?>" />
        <br style="clear:both" />

        <label for="nrendosso"><?php echo utf8ToHtml('Nr. Endosso:') ?></label>
        <input id="nrendosso" name="nrendosso" type="text" value="<?php echo $Nrendosso; ?>" />

        <label for="tpendosso"><?php echo utf8ToHtml('Tipo Endosso:') ?></label>
        <input id="tpendosso" name="tpendosso" type="text" value="<?php echo $tpendosso; ?>" />
        <br style="clear:both" />
        <label for="tpsub_endosso"><?php echo utf8ToHtml('Subtipo Endosso:') ?></label>
        <input id="tpsub_endosso" name="tpsub_endosso" type="text" value="<?php echo $tpsub_endosso; ?>" />

    </fieldset>

    <fieldset style="width:95%;" >
        <legend align="left"><?php echo 'Dados do Ve&iacute;culo' ?></legend>

        <label for="nmmarca"><?php echo utf8ToHtml('Marca:') ?></label>
        <input id="nmmarca" name="nmmarca" type="text" value="<?php echo $Nmmarca; ?>" />
        <label for="dsmodelo"><?php echo utf8ToHtml('Modelo:') ?></label>
        <input id="dsmodelo" name="dsmodelo" type="text" value="<?php echo $Dsmodelo; ?>" />
        <br style="clear:both" />

        <label for="dschassi"><?php echo utf8ToHtml('Chassi:') ?></label>
        <input id="dschassi" name="dschassi" type="text" value="<?php echo $Dschassi; ?>" />
        <label for="dsplaca"><?php echo utf8ToHtml('Placa:') ?></label>
        <input id="dsplaca" name="dsplaca" type="text" value="<?php echo $Dsplaca; ?>" />
        <br style="clear:both" />

        <label for="nranofab"><?php echo utf8ToHtml('Ano Fabr.:') ?></label>
        <input id="nranofab" name="nranofab" type="text" value="<?php echo $Nranofab; ?>" />
        <label for="nranomod"><?php echo utf8ToHtml('Ano Modelo:') ?></label>
        <input id="nranomod" name="nranomod" type="text" value="<?php echo $Nranomod; ?>" />
        <br style="clear:both" />
    </fieldset>

    <fieldset style="width:95%;" >
        <legend align="left"><?php echo 'Dados Complementares' ?></legend>

        <label for="vlfranquia"><?php echo utf8ToHtml('Valor da Franquia:') ?></label>
        <input id="vlfranquia" name="vlfranquia" type="text" value="<?php echo $vlfranquia; ?>"></input>
        <br style="clear:both" />

        <label for="vlpremioliq"><?php echo utf8ToHtml('Pr&ecirc;mio L&iacute;quido:') ?></label>
        <input id="vlpremioliq" name="vlpremioliq" type="text" value="<?php echo $vlpremioliq; ?>"></input>
        <label for="vlpremiotot"><?php echo utf8ToHtml('Pr&ecirc;mio Total:') ?></label>
        <input id="vlpremiotot" name="vlpremiotot" type="text" value="<?php echo $vlpremiotot; ?>"></input>
        <br style="clear:both" />

        <label for="qtparcelas"><?php echo utf8ToHtml('Quantidade de Parcelas:') ?></label>
        <input id="qtparcelas" name="qtparcelas" type="text" value="<?php echo $qtparcelas; ?>"></input>
        <label for="vlparcela"><?php echo utf8ToHtml('Valor da Parcela:') ?></label>
        <input id="vlparcela" name="vlparcela" type="text" value="<?php echo $vlparcela; ?>"></input>
        <br style="clear:both" />

        <label for="diadodebito"><?php echo utf8ToHtml('Melhor dia de Vencimento:') ?></label>
        <input id="diadodebito" name="diadodebito" type="text" value="<?php echo $diadodebito; ?>"></input>
        <label for="percomissao"><?php echo utf8ToHtml('% de Comissão:') ?></label>
        <input id="percomissao" name="percomissao" type="text" value="<?php echo $percomissao; ?>"></input>
    </fieldset>
</form>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao(''); return false;" />
</div>