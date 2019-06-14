<?php 
/*!
 * FONTE        : tab_registros.php                 Última alteração: 24/08/2016
 * CRIAÇÃO      : ANDREI - RKAM
 * DATA CRIAÇÃO : MAIO/2016
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
	
	require_once("../../includes/carrega_permissoes.php");
	?>

<form id="frmBens" name="frmBens" class="formulario" style="display:none;">

  <fieldset id="fsetBens" name="fsetBens" style="margin:0px; padding:10 30 10 30;">

    <legend>Bens</legend>

    <div id="divBens">
	  
	  <input type="hidden" id="permisit" name="permisit" value="<? echo $permissao_situacao; ?>" />
      <input type="hidden" id="situacao_anterior" name="situacao_anterior" />
      <input type="hidden" id="chassi_anterior" name="chassi_anterior" />
	  <input id="dsseqbem" name="dsseqbem" type="hidden" ></input>	  
	  
	  <label for="ddl_descrbem"><? echo utf8ToHtml('Selecione o Veículo:') ?></label>
      <select id="ddl_descrbem" name="ddl_descrbem" >
	  <?foreach($bens as &$bem)
	  {?>
		<option value="<? echo getByTagName($bem->tags,'idseqbem' );?>"><? echo getByTagName($bem->tags,'nrseqbem');?> - <? echo getByTagName($bem->tags,'dsbemfin' );?></option>
	  <?}?>
	  </select>
	  <br />
	  <br />
	  <br />
	  
	  <label for="dtmvttel"><? echo utf8ToHtml('Data do registro:') ?></label>
      <input id="dtmvttel" name="dtmvttel" type="text" ></input>
	  
	  <label for="dssitgrv"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
      <select id="dssitgrv" name="dssitgrv">
		<option value="0">Nao enviado</option>
		<option value="1">Em processamento</option>
		<option value="2">Alienacao</option>
		<option value="3">Processado com Critica</option>
		<option value="4">Baixado</option>
		<option value="5">Cancelado</option>
	  </select>

      <label for="nrgravam"><? echo utf8ToHtml('N&uacute;mero de registro:') ?></label>
      <input id="nrgravam" name="nrgravam" type="text" ></input>
	  
	  <label for="dsblqjud"><? echo utf8ToHtml('Bloqueado:') ?></label>
      <input id="dsblqjud" name="dsblqjud" type="text" ></input>

      <label for="dscatbem"><? echo utf8ToHtml('Categoria:') ?></label>
      <input id="dscatbem" name="dscatbem" type="text" ></input>
	  
	  <label for="vlmerbem"><? echo utf8ToHtml('Valor de mercado:') ?></label>
      <input id="vlmerbem" name="vlmerbem" type="text" ></input>

      <label for="dscorbem"><? echo utf8ToHtml('Cor:') ?></label>
      <input id="dscorbem" name="dscorbem" type="text" ></input>
	  
	  <label for="tpchassi"><? echo utf8ToHtml('Tipo chassi:') ?></label>
      <? echo selectTipoChassi('tpchassi', " - ") ?>

      <label for="dschassi"><? echo utf8ToHtml('Chassi:') ?></label>
      <input id="dschassi" name="dschassi" type="text" ></input>
	  
	  <label for="nrrenava"><? echo utf8ToHtml('RENAVAM:') ?></label>
      <input id="nrrenava" name="nrrenava" type="text" ></input>

      <label for="ufdplaca"><? echo utf8ToHtml('UF/Placa:') ?></label>
      <input id="ufdplaca" name="ufdplaca" type="text" ></input>

      <label for="nrdplaca"></label>
      <input id="nrdplaca" name="nrdplaca" type="text" ></input>
	  
	  <label for="nrmodbem"><? echo utf8ToHtml('Ano do Modelo:') ?></label>
      <input id="nrmodbem" name="nrmodbem" type="text" ></input>
	  
	  <label for="nranobem"><? echo utf8ToHtml('Ano de Fabrica&ccedil;&atilde;o:') ?></label>
      <input id="nranobem" name="nranobem" type="text" ></input>
	  
      <label for="uflicenc"><? echo utf8ToHtml('UF Licenciamento:') ?></label>
      <input id="uflicenc" name="uflicenc" type="text" ></input>

      <label for="dscpfbem"><? echo utf8ToHtml('CPF/CNPJ Interv.:') ?></label>
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

 
  <fieldset id="fsetBens" name="fsetBens" style="margin:0px; padding:10 30 10 30; display: none">

    <legend>Bens</legend>


    <div id="divRegistros" class="divRegistros">

      <table>
        <tbody>
          <? for($i = 0; $i 
        
          < count($bens); $i++){?>

          <tr id="<? echo getByTagName($bens[$i]->tags,'idseqbem'); ?>">
			<td>
				<input type="hidden" id="hdnrseqbem" name="nrseqbem" value="<? echo getByTagName($bens[$i]->tags,'nrseqbem'); ?>" />
				<input type="hidden" id="hdnrgravam" name="nrgravam" value="<? echo getByTagName($bens[$i]->tags,'nrgravam'); ?>" />
				<input type="hidden" id="hddsseqbem" name="dsseqbem" value="<? echo getByTagName($bens[$i]->tags,'dsseqbem'); ?>" />
				<input type="hidden" id="hddsbemfin" name="dsbemfin" value="<? echo getByTagName($bens[$i]->tags,'dsbemfin'); ?>" />
				<input type="hidden" id="hdvlmerbem" name="vlmerbem" value="<? echo getByTagName($bens[$i]->tags,'vlmerbem'); ?>" />
				<input type="hidden" id="hdtpchassi" name="tpchassi" value="<? echo getByTagName($bens[$i]->tags,'tpchassi'); ?>" />
				<input type="hidden" id="hdnrdplaca" name="nrdplaca" value="<? echo mascara(getByTagName($bens[$i]->tags,'nrdplaca'),'#######'); ?>" />
				<input type="hidden" id="hdnranobem" name="nranobem" value="<? echo getByTagName($bens[$i]->tags,'nranobem'); ?>" />
				<input type="hidden" id="hddscpfbem" name="dscpfbem" value="<? echo getByTagName($bens[$i]->tags,'dscpfbem'); ?>" />
				<input type="hidden" id="hduflicenc" name="uflicenc" value="<? echo getByTagName($bens[$i]->tags,'uflicenc'); ?>" />
				<input type="hidden" id="hddscatbem" name="dscatbem" value="<? echo getByTagName($bens[$i]->tags,'dscatbem'); ?>" />
				<input type="hidden" id="hddscorbem" name="dscorbem" value="<? echo getByTagName($bens[$i]->tags,'dscorbem'); ?>" />
				<input type="hidden" id="hddschassi" name="dschassi" value="<? echo getByTagName($bens[$i]->tags,'dschassi'); ?>" />
				<input type="hidden" id="hdnrmodbem" name="nrmodbem" value="<? echo getByTagName($bens[$i]->tags,'nrmodbem'); ?>" />
				<input type="hidden" id="hdufdplaca" name="ufdplaca" value="<? echo getByTagName($bens[$i]->tags,'ufdplaca'); ?>" />
				<input type="hidden" id="hdnrrenava" name="nrrenava" value="<? echo getByTagName($bens[$i]->tags,'nrrenava'); ?>" />
				<input type="hidden" id="hdvlctrgrv" name="vlctrgrv" value="<? echo getByTagName($bens[$i]->tags,'vlctrgrv'); ?>" />
				<input type="hidden" id="hddtoperac" name="dtoperac" value="<? echo getByTagName($bens[$i]->tags,'dtoperac'); ?>" />
				<input type="hidden" id="hddtmvtolt" name="dtmvtolt" value="<? echo getByTagName($bens[$i]->tags,'dtmvtolt'); ?>" />
				<input type="hidden" id="hddssitgrv" name="dssitgrv" value="<? echo getByTagName($bens[$i]->tags,'dssitgrv'); ?>" />
				<input type="hidden" id="hddsblqjud" name="dsblqjud" value="<? echo getByTagName($bens[$i]->tags,'dsblqjud'); ?>" />
				<input type="hidden" id="hdcdsitgrv" name="cdsitgrv" value="<? echo getByTagName($bens[$i]->tags,'cdsitgrv'); ?>" />
				<input type="hidden" id="hdtpctrpro" name="tpctrpro" value="<? echo getByTagName($bens[$i]->tags,'tpctrpro'); ?>" />
				<input type="hidden" id="hdtpjustif" name="tpjustif" value="<? echo getByTagName($bens[$i]->tags,'tpjustif'); ?>" />
				<input type="hidden" id="hddsjustif" name="dsjustif" value="<? echo getByTagName($bens[$i]->tags,'dsjustif'); ?>" />
				<input type="hidden" id="hdpossuictr" name="possuictr" value="<? echo $possuictr; ?>" />
				<input type="hidden" id="hdidseqbem" name="idseqbem" value="<? echo getByTagName($bens[$i]->tags,'idseqbem'); ?>" />
				<input type="hidden" id="hdtpinclus" name="tpinclus" value="<? echo getByTagName($bens[$i]->tags,'tpinclus'); ?>" />
				<input type="hidden" id="hdcdultope" name="cdultope" value="<? echo getByTagName($bens[$i]->tags,'cdultope'); ?>" />
			
			</td>        
          </tr>

          <?}?>

        </tbody>
      </table>
    </div>

  </fieldset>

</form>

<div id="divBotoesBens" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	<a href="#" class="botao" id="btVoltar" 		onclick="controlaVoltar('5'); 		return false;">Voltar</a>
	
	<a href="#" class="botao" id="btIncluir" style="display:none;"  onclick="validPermiss('M'); return false;">Incluir</a>
	<a href="#" class="botao" id="btAlterar" style="display:none;" onclick="validPermiss('A'); return false;">Alterar</a>	
	<a href="#" class="botao" id="btCancelar" style="display:none;" onclick="validPermiss('X'); return false;">Cancelamento</a>
	<a href="#" class="botao" id="btBaixar"  style="display:none;" onclick="validPermiss('B'); return false;">Baixar</a>
	
	<a href="#" class="botao" id="btLibJudicial" style="display:none;" onclick="validPermiss('L'); 	return false;">Libera&ccedil;&atilde;o Judicial</a>																																			
	<a href="#" class="botao" id="btBlocJudicial" style="display:none;" onclick="validPermiss('J'); 	return false;">Bloqueio Judicial</a>

	<a href="#" class="botao" id="btBaixaManual" style="display:none;" onclick="validPermiss('Z'); return false;">Baixa Manual</a>	
	
	<a href="#" class="botao" style="display:none;" id="btConcluirAltera"><? echo utf8ToHtml('Concluir Alterações') ?></a>
	
	<a href="#" class="botao" id="btHistGravame" style="display:none;" ><? echo utf8ToHtml("Histórico Gravame") ?></a>	
												
	<a href="#" class="botao" style="display:none;" id="btConcluir">Concluir</a>
	<!--<a href="#" class="botao" id="btConcluir" onclick="controlaConcluir(); return false;">Concluir</a>
	<!--<a href="#" class="botao" id="btConcluir" onclick="showConfirmacao('Deseja concluir a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'controlaConcluir();', '', 'sim.gif', 'nao.gif'); return false;">Concluir</a>
	-->
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


</script>

<style type="text/css">
#frmBens label.rotulo-linha {
    margin-left: 43px;
    width: 110px;
    text-align: left;
}
form.formulario label.rotulo {
	width: 120px;
	text-align: left;
}
</style>