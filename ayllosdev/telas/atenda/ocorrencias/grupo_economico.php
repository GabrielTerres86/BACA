<?php 

	/************************************************************************
	      Fonte: grupo_economico.php
	      Autor: Adriano
	      Data : Outubro/2012              		Última Alteração: 21/09/2018

          Objetivo  : Mostrar opcao de Grupo Economico da rotina de Ocorrencias
                      da tela ATENDA

	      Alterações: 21/03/2013 - Ajustes realizados:
                               - Corrigido a grafia do título da coluna "Endividamento"
                               - Atribuido o valor correto a coluna "Endividamento" 
                               (Adriano).
                    12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
                    10/02/2014 - Correção relativa ao Valor do Endividamento (Lucas).
                    25/07/2016 - Corrigi a forma de recuperacao dos dados do XML. SD 479874 (Carlos R.)
                    21/09/2018 - P450 - Correção da formatação do CPF/CNPJ (Guilherme/AMcom)
											
	************************************************************************/

	session_start();

	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	

	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlBuscaGrupo  = "";
	$xmlBuscaGrupo .= "<Root>";
	$xmlBuscaGrupo .= "	<Cabecalho>";
	$xmlBuscaGrupo .= "		<Bo>b1wgen0138.p</Bo>";
	$xmlBuscaGrupo .= "		<Proc>busca_grupo</Proc>";
	$xmlBuscaGrupo .= "	</Cabecalho>";
	$xmlBuscaGrupo .= "	<Dados>";
	$xmlBuscaGrupo .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlBuscaGrupo .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaGrupo .= "	</Dados>";
	$xmlBuscaGrupo .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlBuscaGrupo);

	// Cria objeto para classe de tratamento de XML
	$xmlObjBuscaGrupo = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjBuscaGrupo->roottag->tags[0]->name) && strtoupper($xmlObjBuscaGrupo->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBuscaGrupo->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
    
	$pertgrup = ( isset($xmlObjBuscaGrupo->roottag->tags[0]->attributes['PERTGRUP']) ) ? $xmlObjBuscaGrupo->roottag->tags[0]->attributes['PERTGRUP'] : null;
	$gergrupo = ( isset($xmlObjBuscaGrupo->roottag->tags[0]->attributes['GERGRUPO']) ) ? $xmlObjBuscaGrupo->roottag->tags[0]->attributes['GERGRUPO'] : null;
	$nrdgrupo = ( isset($xmlObjBuscaGrupo->roottag->tags[0]->attributes['NRDGRUPO']) ) ? $xmlObjBuscaGrupo->roottag->tags[0]->attributes['NRDGRUPO'] : null;
			
	if($gergrupo != ""){
						
		echo '<script type="text/javascript">';
		echo '   hideMsgAguardo();';
		echo '   showError("error","'.$gergrupo.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		
	}	
		
	if($pertgrup){
			
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlCalEndivRiscoGrupo  = "";
		$xmlCalEndivRiscoGrupo .= "<Root>";
		$xmlCalEndivRiscoGrupo .= "	<Cabecalho>";
		$xmlCalEndivRiscoGrupo .= "		<Bo>b1wgen0138.p</Bo>";
		$xmlCalEndivRiscoGrupo .= "		<Proc>calc_endivid_grupo</Proc>";
		$xmlCalEndivRiscoGrupo .= "	</Cabecalho>";
		$xmlCalEndivRiscoGrupo .= "	<Dados>";
		$xmlCalEndivRiscoGrupo .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlCalEndivRiscoGrupo .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlCalEndivRiscoGrupo .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlCalEndivRiscoGrupo .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlCalEndivRiscoGrupo .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlCalEndivRiscoGrupo .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlCalEndivRiscoGrupo .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlCalEndivRiscoGrupo .= "		<nrdgrupo>".$nrdgrupo."</nrdgrupo>";
		$xmlCalEndivRiscoGrupo .= "		<tpdecons>true</tpdecons>"; /*Consulta por conta*/
		$xmlCalEndivRiscoGrupo .= "	</Dados>";
		$xmlCalEndivRiscoGrupo .= "</Root>";

		// Executa script para envio do XML
		$xmlResultCalcEndivRiscoGrupo = getDataXML($xmlCalEndivRiscoGrupo);

		// Cria objeto para classe de tratamento de XML
		$xmlObjCalcEndivRiscoGrupo = getObjectXML($xmlResultCalcEndivRiscoGrupo);
		
		if (isset($xmlCalEndivRiscoGrupo->roottag->tags[0]->name) && strtoupper($xmlCalEndivRiscoGrupo->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlCalEndivRiscoGrupo->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		
		$dsdrisco = ( isset($xmlObjCalcEndivRiscoGrupo->roottag->tags[0]->attributes['DSDRISCO']) ) ? $xmlObjCalcEndivRiscoGrupo->roottag->tags[0]->attributes['DSDRISCO'] : '';
		$vlendivi = ( isset($xmlObjCalcEndivRiscoGrupo->roottag->tags[0]->attributes['VLENDIVI']) ) ? $xmlObjCalcEndivRiscoGrupo->roottag->tags[0]->attributes['VLENDIVI'] : 0;
		$grupo    = ( isset($xmlObjCalcEndivRiscoGrupo->roottag->tags[1]->tags) ) ? $xmlObjCalcEndivRiscoGrupo->roottag->tags[1]->tags : array();
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","");';
		echo '</script>';
		exit();
	}

?>


<div id="divGrupoEconomico" >

	<form name="frmGrupoEconomico" id="frmGrupoEconomico" class="formulario">
	
		<br />
		
		<label for="dsdrisco">Risco do Grupo:</label>
		<input name="dsdrisco" id="dsdrisco" type="text" value="<?php echo $dsdrisco; ?>" />
		
		<label for="vlendivi">Endividamento do Grupo:</label>
		<input name="vlendivi" id="vlendivi" type="text" value="<?php echo formataMoeda($vlendivi); ?>" />
		
	
	</form>
	
	<br style="clear:both" />
	<br style="clear:both" />
	
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('CPF');  ?></th>
					<th><? echo utf8ToHtml('Risco');  ?></th>
					<th><? echo utf8ToHtml('Endividamento');  ?></th>
					
				</tr>
			</thead>
			<tbody>
				<? 
                for ($i = 0; $i < count($grupo); $i++) {
				?>
					<tr>
						<td><span><?php echo $grupo[$i]->tags[10]->cdata; ?></span>
								<?php echo $grupo[$i]->tags[10]->cdata; ?>
								
						</td>
						<td><span><?php echo $grupo[$i]->tags[2]->cdata; ?></span>
								<?php echo formataContaDV($grupo[$i]->tags[2]->cdata); ?>																
						</td>
						<td><span><?php echo $grupo[$i]->tags[5]->cdata;  ?></span>
                        <?php
                          if (getByTagName($grupo[$i]->tags,"inpessoa") == 1){
                            echo mascaraCpf($grupo[$i]->tags[5]->cdata);
                          }
                          else {
                            echo mascaraCnpj($grupo[$i]->tags[5]->cdata);
                          }
                          ?>
						</td>
						<td><span><?php echo $grupo[$i]->tags[6]->cdata; ?></span>
								<?php echo $grupo[$i]->tags[6]->cdata; ?>
						</td>
						<td>
							<span><?php echo formataMoeda(getByTagName($grupo[$i]->tags,"vlendivi")); ?></span>
								<?php echo formataMoeda(getByTagName($grupo[$i]->tags,"vlendivi")); ?>
						</td>
						
	
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	
</div>

<script type="text/javascript">
// Formata layout
formataGrupoEconomico();

<?if($gergrupo == ""){ ?>

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
<?}?>

</script>
