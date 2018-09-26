<?php 

	/***************************************************************************
	      Fonte: contas_cadastradas.php      	                           
	      Autor: Lucas                                                     
	      Data : Maio/2012                   Última Alteração: 08/09/2018	       
	                                                                     
	      Objetivo  : Mostrar contas de tranf. cadastradas			       
	                                                                     	 
	                                                                       	 
	      Alterações: 08/04/2013 - Transferencia intercooperativa (Gabriel)	
                    24/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)
                    08/09/2018 - Paginacao na tela de Contas de Outras IFs (Andrey Formigari - Mouts)
	                                                                     
	                                                                      
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
  
  $intipdif = $_POST["intipdif"];
	$qtregist = 0;
	$qtregpag = 50;
	$qtregini = ((isset($_POST["qtregini"])) ? $_POST["qtregini"] : 0);
	$qtregfim = ((isset($_POST["qtregfim"])) ? $_POST["qtregfim"] : $qtregpag);
			
	?>

<script type="text/javascript">
  var intipdif;
</script>
	
<div id="divBotoes" style="margin-bottom:10px">
	<input type="image" src="<? echo $UrlImagens; ?>botoes/contas_sistema_ailos.gif" onClick="obtemCntsCad(1, 0, <? echo $qtregpag; ?>);intipdif = 1;return false;" />
  <input type="image" src="<? echo $UrlImagens; ?>botoes/contas_de_outras_ifs.gif" onClick="obtemCntsCad(2, 0, <? echo $qtregpag; ?>);intipdif = 2;return false;"  />
</div>
	
<?php
	$intipdif = $_POST["intipdif"];
	
	//Não mostra nenhum Form se o tipo de IF não for espeificado
	if ($intipdif == 0){
	
?>
		<div id="divBotoes" style="margin-bottom:10px">
			<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="redimensiona(); carregaContas(); return false;" />
		</div>

		<script type="text/javascript">

			hideMsgAguardo();
			blockBackground(parseInt($("#divRotina").css("z-index")));
			
			$("#divConteudoOpcao").css("height","85");
			
			reg = new Array();
			
		</script>
	
	<?php
		exit();
	}
			
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetCadastradas  = "";
	$xmlGetCadastradas .= "<Root>";
	$xmlGetCadastradas .= "	<Cabecalho>";
	$xmlGetCadastradas .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetCadastradas .= "		<Proc>consulta-contas-cadastradas</Proc>";
	$xmlGetCadastradas .= "	</Cabecalho>";
	$xmlGetCadastradas .= "	<Dados>";
	$xmlGetCadastradas .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetCadastradas .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetCadastradas .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetCadastradas .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetCadastradas .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlGetCadastradas .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetCadastradas .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetCadastradas .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlGetCadastradas .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetCadastradas .= "		<intipdif>".$intipdif."</intipdif>";
	$xmlGetCadastradas .= "		<inpessoa>0</inpessoa>";
  $xmlGetCadastradas .= "		<qtregini>".$qtregini."</qtregini>";
	$xmlGetCadastradas .= "		<qtregfim>".$qtregfim."</qtregfim>";
	$xmlGetCadastradas .= "	</Dados>";
	$xmlGetCadastradas .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetCadastradas);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCadastradas = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjCadastradas->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCadastradas->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$registros = $xmlObjCadastradas->roottag->tags[0]->tags;
  $qtregist = $xmlObjCadastradas->roottag->tags[0]->attributes['QTREGIST'];
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	//Define o nome do FIELDSET dependo do tipo de IF
	if ($intipdif==1){
	
		$fieldset = "Contas do Sistema CECRED";
		
	} else {
	
		$fieldset = "Contas de Outras IFs";
		
	}
	
?>

<form id="tabContas" class="formulario">
	<fieldset>
		<legend> <? echo $fieldset ?> </legend>

		<div class="divRegistros">	
			<table class="tituloRegistros">
				<thead>
					<tr>
						<th><?php if ($intipdif == 1 ) {  echo utf8ToHtml('Cooperativa'); }  else { echo utf8ToHtml('Banco'); } ?></th>
						<th><? echo utf8ToHtml('Conta/DV');  ?></th>
						<th><? echo utf8ToHtml('Titular');   ?></th>
						<th><? echo utf8ToHtml('Situação');  ?></th>
					</tr>
				</thead>
				<tbody>
					<?
						$i = 0;
						foreach ( $registros as $contas ) {
					?>
					
						<tr onClick="detalhesCntsCad( <? echo $i; ?> );return false;">							
							<td><span><? echo getByTagName($contas->tags,'dsageban'); ?></span>
									  <? echo getByTagName($contas->tags,'dsageban'); ?>
							</td>
							<td><span><? echo getByTagName($contas->tags,'dsctatrf'); ?></span>
									  <? echo getByTagName($contas->tags,'dsctatrf'); ?>
							</td>
							<td><span><? echo getByTagName($contas->tags,'nmtitula'); ?></span>
									  <? echo stringTabela(getByTagName($contas->tags,'nmtitula'),50,'maiuscula'); ?>
							</td>
							<td><span><? echo getByTagName($contas->tags,'dssitcta'); ?></span>
									  <? echo getByTagName($contas->tags,'dssitcta'); ?>
							</td>
							
						</tr>
						<script type="text/javascript">
						
						//Armazena TODOS os valores em um array de objetos para exibir nos Forms de Detalhes
						ObjReg = new Object(); 		
						ObjReg.cddbanco = '<? echo getByTagName($contas->tags,'cddbanco') == '0' ? ' ' : str_pad(getByTagName($contas->tags,'cddbanco'), 3, "0", STR_PAD_LEFT) ?>'; 
						ObjReg.cdispbif = '<? echo (getByTagName($contas->tags,'nrispbif') == '0' && getByTagName($contas->tags,'cddbanco') != 1)  ? ' ' : str_pad(getByTagName($contas->tags,'nrispbif'), 8, "0", STR_PAD_LEFT) ?>'; 
                        ObjReg.cdageban = '<? echo getByTagName($contas->tags,'cdageban') ?>'; 
						ObjReg.nrctatrf = '<? echo getByTagName($contas->tags,'nrctatrf') ?>'; 
						ObjReg.nmtitula = '<? echo getByTagName($contas->tags,'nmtitula') ?>'; 
						ObjReg.nrcpfcgc = '<? echo getByTagName($contas->tags,'nrcpfcgc') ?>'; 
						ObjReg.dstransa = '<? echo getByTagName($contas->tags,'dstransa') ?>'; 
						ObjReg.dsoperad = '<? echo getByTagName($contas->tags,'dsoperad') ?>';
						ObjReg.insitcta = '<? echo getByTagName($contas->tags,'insitcta') ?>';
						ObjReg.dssitcta = '<? echo getByTagName($contas->tags,'dssitcta') ?>';
						ObjReg.intipdif = '<? echo getByTagName($contas->tags,'intipdif') ?>';
						ObjReg.dsctatrf = '<? echo getByTagName($contas->tags,'dsctatrf') ?>'; 
						ObjReg.intipcta = '<? echo getByTagName($contas->tags,'intipcta') ?>'; 
						ObjReg.inpessoa = '<? echo getByTagName($contas->tags,'inpessoa') ?>'; 
						ObjReg.dscpfcgc = '<? echo getByTagName($contas->tags,'dscpfcgc') ?>'; 
						ObjReg.dsageban = '<? echo getByTagName($contas->tags,'dsageban') ?>';

						reg[<? echo $i ?>] = ObjReg;
						
					</script>
					<? 
						$i++;
						} ?>	
				</tbody>
			</table>		
		</div>
    <div id="divPesquisaRodape" class="divPesquisaRodape ">
      <table>
        <tr>
          <td>
            <?
							
							//
							if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
							
							// Se a paginação não está na primeira, exibe botão voltar
							if ($qtregini > 0) { 
								?> <a class='paginacaoAnt'>
              <<< Anterior</a> <? 
							} else {
								?> &nbsp; <?
							}
						?>
					
          </td>
          <td>
            <?
							if ($qtregist > 0) { 
								?> Exibindo <? echo (($qtregini==0) ? 1 : $qtregini); ?> at&eacute; <? echo (($qtregfim > $qtregist) ? $qtregist : $qtregfim); ?> de <? echo $qtregist; ?><?
							}
						?>
					
          </td>
          <td>
            <?
							// Se a paginação não está na &uacute;ltima página, exibe botão proximo
            if ($qtregist > $qtregfim) {
            ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
							} else {
								?> &nbsp; <?
							}
						?>			
					
          </td>
        </tr>
      </table>
    </div>
	</fieldset>
	<div id="divBotoes" style="margin-bottom:10px">
		<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="redimensiona(); carregaContas(); return false;" />
	</div>
</form>
<style type="text/css">
  form.formulario a{ padding: 0; }
</style>
<script type="text/javascript">

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
  $("#divConteudoOpcao").css("width","775");
  $("#divConteudoOpcao").css("height","255");

  //Chama funcao para controle da lista de Contas Cadastradas
  controlaListaCntsCad();

  // Esconde mensagem de aguardo
  hideMsgAguardo();
  blockBackground(parseInt($("#divRotina").css("z-index")));

  $("#divRotina").css("width","845px");
  $("#divRotina").centralizaRotinaH();

  $('a.paginacaoAnt').unbind('click').bind('click', function() {
    obtemCntsCad(intipdif, <? echo "'".($qtregini - $qtregpag)."','".($qtregfim-$qtregpag)."'"; ?>);
  });
  $('a.paginacaoProx').unbind('click').bind('click', function() {
	  obtemCntsCad(intipdif, <? echo "'".($qtregini + $qtregpag)."','".($qtregfim + $qtregpag)."'"; ?>);
  });	

  $('#divPesquisaRodape','#tabContas').formataRodapePesquisa();
</script> 