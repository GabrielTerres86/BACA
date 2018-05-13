<?
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();
$nrdconta = $_POST["nrdconta"];
$nrctrcrd = $_POST["nrctrcrd"];



$lista = array();
//nrdconta,nrctremp,dtinicio,dtafinal,tpproduto
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrctremp>" . $nrctrcrd . "</nrctremp>";
$xml .= "   <tpproduto>4</tpproduto>";
$xml .= "   <dtinicio>01/01/1900</dtinicio>";
$xml .= "   <dtafinal>31/12/4712</dtafinal>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CONPRO", "CONPRO_ACIONAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

$response = simplexml_load_string($xmlResult);

$counter = count($response->Dados->inf );



?>
<fieldset>
    <legend> <? echo utf8ToHtml("Histórico da Proposta: ") . $nrctrcrd; ?> </legend>
    <table width="100%" border="0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
        <tr>
            <td align="center">
                <table width="660" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
                    <tr>
                        <td>


                            <div id="divRotina"></div>
                            <div id="divUsoGenerico"></div>
                            <div id="divTela">
                                <div id="registrosDiv" class="hideable">
                                    <div id="tabConcon">
                                        <table class="tituloRegistros">
                                            <thead>
                                            <tr>
                                                <th id="admCell" class=" admCell" style="width: 68px;">Acionamento</th>
                                                <th id="limCell" class=" limCell"style="width: 89px;">PA</th>
                                                <th id="limiteCell" class=" limiteCell" >Operador</th>
                                                <th id="diadebitoCell"
                                                    class=" diadebitoCell" ><? echo utf8ToHtml("Operação") ?> </th>
                                                <th id="tipocell" class="tipocell"style="width: 112px;">Data e Hora</th>
                                                <th id="tipocell" class="tipocell">Retorno</th>
                                                <th class="ordemInicial"></th>
                                            </tr>
                                            </thead>
                                        </table>
                                    </div>
                                    <div class=" divRegistros">
                                        <table id="registros" class=" tituloRegistros">
                                            <thead>
							
                                            <thead>
                                            <tbody>
												<?php
													$key = 0;
													if($counter > 0){
													foreach($response->Dados->inf as  $tem){
														if ($key % 2 == 0) {
															$class =  "even corImpar";
														}else{
															$class =  "odd corPar";
														}
														$key++;
													?>
													
													<tr class="<? echo $class." ".$key; ?>">
													<td style="    width: 70px;" key="<? echo $key; ?>"><?php echo $tem->acionamento; ?> </td>
													<td style="    width: 90px;"><?php echo utf8ToHtml($tem->nmagenci); ?> </td>
													<td style="    width: 103px;"><?php echo utf8ToHtml($tem->cdoperad); ?> </td>
													<td style="    width: 108px;"><?php echo utf8ToHtml($tem->operacao); ?> </td>
													<td><?php echo utf8ToHtml($tem->dtmvtolt); ?> </td>
													<td style="    width: 87px;"><?php echo utf8ToHtml($tem->retorno); ?> </td>
													</tr>
													<?
													}
													}
												?>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                                <div id="divBotoes" style='border-top:1px solid #777'>								    
									<a href="#" onclick="consultaCartao();"  class="botao" id="btVoltar">Voltar</a>
									<a href="#" onclick="enviarBancoob(<?php echo $nrctrcrd; ?>);" class="botao" id="btRenviar">Xunxo reenvio</a>
									<a href="#" onclick="verificaRetornoBancoob(<?php echo $nrctrcrd; ?>);" class="botao" id="btRenviar">Xunxo retorno</a>
                                </div>
                            </div>
                        </td>
                    </tr>

                </table>
            </td>
        </tr>
    </table>
</fieldset>

<script>
    function back() {
        $("#divOpcoesDaOpcao1").hide();
        $("#divConteudoCartoes").show();
    }

</script>