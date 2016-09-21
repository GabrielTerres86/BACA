<?php 
/*!
 * FONTE        : tab_registros.php                 Última alteração: 14/07/2016
 * CRIAÇÃO      : ANDREI - RKAM
 * DATA CRIAÇÃO : mAIO/2016
 * OBJETIVO     : Tabela que apresenta a consulta de ratings da tela RATING
 * --------------
 * ALTERAÇÕES   :  14/07/2016 - Ajustar nome do renvam (Andrei - RKAM).
 *                 
 *                 24/08/2016 - Validar se pode ser alterado a situação do GRAVAMES. Projeto 369 (Lombardi).
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmBens" name="frmBens" class="formulario" style="display:none;">

  <fieldset id="fsetBens" name="fsetBens" style="padding:0px; margin:0px; padding-bottom:10px;">

    <legend>Bens</legend>

    <div id="divBens">
	  
	  <input type="hidden" id="permisit" name="permisit" value="<? echo $permissao_situacao; ?>" />
      <input type="hidden" id="situacao_anterior" name="situacao_anterior" />
      <input type="hidden" id="chassi_anterior" name="chassi_anterior" />
	  
	  <label for="dtmvttel"><? echo utf8ToHtml('Data do registro:') ?></label>
      <input id="dtmvttel" name="dtmvttel" type="text" ></input>

      <label for="dsseqbem"></label>
      <input id="dsseqbem" name="dsseqbem" type="text" ></input>

      <br />

      <label for="nrgravam"><? echo utf8ToHtml('N&uacute;mero de registro:') ?></label>
      <input id="nrgravam" name="nrgravam" type="text" ></input>

      <label for="dssitgrv"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
      <select id="dssitgrv" name="dssitgrv">
		<option value="0">Nao enviado</option>
		<option value="1">Em processamento</option>
		<option value="2">Alienacao</option>
		<option value="3">Processado com Critica</option>
		<option value="4">Baixado</option>
		<option value="5">Cancelado</option>
	  </select>

      <br />

      <label for="dscatbem"><? echo utf8ToHtml('Categoria:') ?></label>
      <input id="dscatbem" name="dscatbem" type="text" ></input>

      <label for="dsblqjud"><? echo utf8ToHtml('Bloqueado:') ?></label>
      <input id="dsblqjud" name="dsblqjud" type="text" ></input>

      <br />

      <label for="dsbemfin"><? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>
      <input id="dsbemfin" name="dsbemfin" type="text" ></input>

      <br />

      <label for="dscorbem"><? echo utf8ToHtml('Cor/Classe:') ?></label>
      <input id="dscorbem" name="dscorbem" type="text" ></input>

      <label for="vlmerbem"><? echo utf8ToHtml('Valor de mercado:') ?></label>
      <input id="vlmerbem" name="vlmerbem" type="text" ></input>

      <br />

      <label for="dschassi"><? echo utf8ToHtml('Chassi/N&#186;. S&eacute;rie:') ?></label>
      <input id="dschassi" name="dschassi" type="text" ></input>

      <label for="tpchassi"><? echo utf8ToHtml('Tipo chassi:') ?></label>
      <input id="tpchassi" name="tpchassi" type="text" ></input>

      <br />

      <label for="ufdplaca"><? echo utf8ToHtml('UF/Placa:') ?></label>
      <input id="ufdplaca" name="ufdplaca" type="text" ></input>

      <label for="nrdplaca"></label>
      <input id="nrdplaca" name="nrdplaca" type="text" ></input>

      <label for="uflicenc"><? echo utf8ToHtml('UF Licenciamento:') ?></label>
      <input id="uflicenc" name="uflicenc" type="text" ></input>

      <label for="nrrenava"><? echo utf8ToHtml('RENAVAM:') ?></label>
      <input id="nrrenava" name="nrrenava" type="text" ></input>

      <label for="nranobem"><? echo utf8ToHtml('Ano de Fabrica&ccedil;&atilde;o:') ?></label>
      <input id="nranobem" name="nranobem" type="text" ></input>

      <label for="nrmodbem"><? echo utf8ToHtml('Ano/Modelo:') ?></label>
      <input id="nrmodbem" name="nrmodbem" type="text" ></input>

      <label for="dscpfbem"><? echo utf8ToHtml('CPF/CNPJ Prop.:') ?></label>
      <input id="dscpfbem" name="dscpfbem" type="text" ></input>

      <br />

      <label for="vlctrgrv"><? echo utf8ToHtml('Valor Op.:') ?></label>
      <input id="vlctrgrv" name="vlctrgrv" type="text" ></input>

      <label for="dtoperac"><? echo utf8ToHtml('Data da Opera&ccedil;&atilde;o:') ?></label>
      <input id="dtoperac" name="dtoperac" type="text" ></input>

      <br />

    </div>

    <div id="divJustificativa">

      <label for="dsjustif"></label>
      <textarea name="dsjustif" id="dsjustif"></textarea>

      <br />

    </div>


  </fieldset>

  <fieldset id="fsetBens" name="fsetBens" style="padding:0px; margin:0px; padding-bottom:10px;">

    <legend>Bens</legend>


    <div id="divRegistros" class="divRegistros">

      <table>
        <thead>
          <tr>
            <th>Sequ&ecirc;ncial</th>
            <th>Descri&ccedil;&atilde;o</th>
          </tr>
        </thead>
        <tbody>
          <? for($i = 0; $i 
        
          < count($bens); $i++){?>

          <tr>
            <td>
              <span>
                <? echo getByTagName($bens[$i]->tags,'nrseqbem'); ?>
            
              </span>
              <? echo getByTagName($bens[$i]->tags,'nrseqbem'); ?> 
          
            </td>
            <td>
              <span>
                <? echo getByTagName($bens[$i]->tags,'dscatbem'); ?>
            
              </span>
              <? echo getByTagName($bens[$i]->tags,'dscatbem'); ?> 
          
            </td>

            <input type="hidden" id="nrgravam" name="nrgravam" value="<? echo getByTagName($bens[$i]->tags,'nrgravam'); ?>" />
            <input type="hidden" id="dsseqbem" name="dsseqbem" value="<? echo getByTagName($bens[$i]->tags,'dsseqbem'); ?>" />
            <input type="hidden" id="dsbemfin" name="dsbemfin" value="<? echo getByTagName($bens[$i]->tags,'dsbemfin'); ?>" />
            <input type="hidden" id="vlmerbem" name="vlmerbem" value="<? echo getByTagName($bens[$i]->tags,'vlmerbem'); ?>" />
            <input type="hidden" id="tpchassi" name="tpchassi" value="<? echo getByTagName($bens[$i]->tags,'tpchassi'); ?>" />
            <input type="hidden" id="nrdplaca" name="nrdplaca" value="<? echo mascara(getByTagName($bens[$i]->tags,'nrdplaca'),'###-####'); ?>" />
            <input type="hidden" id="nranobem" name="nranobem" value="<? echo getByTagName($bens[$i]->tags,'nranobem'); ?>" />
            <input type="hidden" id="dscpfbem" name="dscpfbem" value="<? echo getByTagName($bens[$i]->tags,'dscpfbem'); ?>" />
            <input type="hidden" id="uflicenc" name="uflicenc" value="<? echo getByTagName($bens[$i]->tags,'uflicenc'); ?>" />
            <input type="hidden" id="dscatbem" name="dscatbem" value="<? echo getByTagName($bens[$i]->tags,'dscatbem'); ?>" />
            <input type="hidden" id="dscorbem" name="dscorbem" value="<? echo getByTagName($bens[$i]->tags,'dscorbem'); ?>" />
            <input type="hidden" id="dschassi" name="dschassi" value="<? echo getByTagName($bens[$i]->tags,'dschassi'); ?>" />
            <input type="hidden" id="nrmodbem" name="nrmodbem" value="<? echo getByTagName($bens[$i]->tags,'nrmodbem'); ?>" />
            <input type="hidden" id="ufdplaca" name="ufdplaca" value="<? echo getByTagName($bens[$i]->tags,'ufdplaca'); ?>" />
            <input type="hidden" id="nrrenava" name="nrrenava" value="<? echo getByTagName($bens[$i]->tags,'nrrenava'); ?>" />
            <input type="hidden" id="vlctrgrv" name="vlctrgrv" value="<? echo getByTagName($bens[$i]->tags,'vlctrgrv'); ?>" />
            <input type="hidden" id="dtoperac" name="dtoperac" value="<? echo getByTagName($bens[$i]->tags,'dtoperac'); ?>" />
            <input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($bens[$i]->tags,'dtmvtolt'); ?>" />
            <input type="hidden" id="dssitgrv" name="dssitgrv" value="<? echo getByTagName($bens[$i]->tags,'dssitgrv'); ?>" />
            <input type="hidden" id="dsblqjud" name="dsblqjud" value="<? echo getByTagName($bens[$i]->tags,'dsblqjud'); ?>" />
            <input type="hidden" id="cdsitgrv" name="cdsitgrv" value="<? echo getByTagName($bens[$i]->tags,'cdsitgrv'); ?>" />
            <input type="hidden" id="tpctrpro" name="tpctrpro" value="<? echo getByTagName($bens[$i]->tags,'tpctrpro'); ?>" />
            <input type="hidden" id="tpjustif" name="tpjustif" value="<? echo getByTagName($bens[$i]->tags,'tpjustif'); ?>" />
            <input type="hidden" id="dsjustif" name="dsjustif" value="<? echo getByTagName($bens[$i]->tags,'dsjustif'); ?>" />
            <input type="hidden" id="possuictr" name="possuictr" value="<? echo $possuictr; ?>" />
            <input type="hidden" id="idseqbem" name="idseqbem" value="<? echo getByTagName($bens[$i]->tags,'idseqbem'); ?>" />
            <input type="hidden" id="tpinclus" name="tpinclus" value="<? echo getByTagName($bens[$i]->tags,'tpinclus'); ?>" />
          </tr>

          <?}?>

        </tbody>
      </table>
    </div>
    <div id="divPesquisaRodape" class="divPesquisaRodape">
      <table>
        <tr>
          <td>
            <?if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
							  if ($nriniseq > 1) {
								  ?> <a class='paginacaoAnt'>
              <<< Anterior</a> <?
							  } else {
								  ?> &nbsp; <?
							  }?>
						
        
          </td>
          <td>
            <? if (isset($nriniseq)) { ?>
								Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
						<? } ?>					
        
          </td>
          <td>
            <? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
								  
          
            <a class="paginacaoProx">Pr&oacute;ximo >>></a>

            <? }?>
									
						
        
          </td>
        </tr>
      </table>
    </div>

  </fieldset>

</form>

<div id="divBotoesBens" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	<a href="#" class="botao" id="btVoltar" onclick="controlaVoltar('2'); return false;">Voltar</a>
  <a href="#" class="botao" id="btConcluir">Concluir</a>
	<!-- <a href="#" class="botao" id="btConcluir" onclick="showConfirmacao('Deseja concluir a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaConcluir();', '', 'sim.gif', 'nao.gif'); return false;">Concluir</a>-->
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaBens( <? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?> );
    });

	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscaBens(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);

  });

  $('#divPesquisaRodape').formataRodapePesquisa();
  $('#divTabela').css('display','block');
  $('#divBotoes').css('display','none');
  $('#divBotoesBens').css('display','block');
  $('#btVoltar','#divBotoesBens').css('visible');

  if($('#cddopcao','#frmCab').val() == 'C' ){

    $('#btConcluir','#divBotoesBens').css('display','none');

  }

  $('#frmBens').css('display', 'block');

  formataFormularioBens();
  formataTabelaBens();

</script>