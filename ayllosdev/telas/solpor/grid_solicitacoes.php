<?php
/* !
 * FONTE        : grid_solicitacoes.php
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/2018
 * OBJETIVO     : Grid das solicitações de portabilidade de salário
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
session_start();
	
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();
// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

$cddopcao = (!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cdcooper = (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';
$nrdconta = (!empty($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$cdagenci = (!empty($_POST['cdagenci'])) ? $_POST['cdagenci'] : '';
$dtsolicitacao_ini = (!empty($_POST['dtsolicitacao_ini'])) ? $_POST['dtsolicitacao_ini'] : ''; 
$dtsolicitacao_fim = (!empty($_POST['dtsolicitacao_fim'])) ? $_POST['dtsolicitacao_fim'] : ''; 
$dtretorno_ini = (!empty($_POST['dtretorno_ini'])) ? $_POST['dtretorno_ini'] : '';     
$dtretorno_fim = (!empty($_POST['dtretorno_fim'])) ? $_POST['dtretorno_fim'] : '';     
$idsituacao = (!empty($_POST['idsituacao'])) ? $_POST['idsituacao'] : '';
$nuPortabilidade = (!empty($_POST['nuPortabilidade'])) ? $_POST['nuPortabilidade'] : '';
$pagina = (!empty($_POST['pagina'])) ? $_POST['pagina'] : 1;
$tamanho_pagina = 10;

// Validação para garantir injeção de parametro
// Caso não for Aillos
if ($glbvars["cdcooper"] <> 3) {
    // Caso o valor informado for diferente da cooperativa logada
    if ($cdcooper <> $glbvars["cdcooper"]) {
        $cdcooper = $glbvars["cdcooper"];
    }
}

function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.addslashes($msgErro).'","Alerta - Aimaro","");';
	echo '</script>';
	exit();
}

$xml = new XmlMensageria();
$xml->add('cdcooper',$cdcooper);
$xml->add('nrdconta',$nrdconta);
$xml->add('cdagenci',$cdagenci);
$xml->add('dtsolicitacao_ini',$dtsolicitacao_ini);
$xml->add('dtsolicitacao_fim',$dtsolicitacao_fim);
$xml->add('dtretorno_ini',$dtretorno_ini);
$xml->add('dtretorno_fim',$dtretorno_fim);
$xml->add('idsituacao',$idsituacao);
$xml->add('nuportabilidade',$nuPortabilidade);
$xml->add('pagina',$pagina);
$xml->add('tamanho_pagina',$tamanho_pagina);

$xmlResult = "";
if ($cddopcao == 'M' || $cddopcao == 'R') {
    $xmlResult = mensageria($xml, "SOLPOR", "BUSCA_PORTABILIDADE_RETORNO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
} else if($cddopcao == 'E') {
    $xmlResult = mensageria($xml, "SOLPOR", "BUSCA_PORTABILIDADE_ENVIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
} else {
    exibeErro("Opção inválida.");
}
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    exibeErro($msgErro);
}

$solicitacoes = $xmlObj->roottag->tags[0]->tags[0]->tags;
?>

<div id="divGrid">
<div class="divRegistros">	
    <table style="table-layout: fixed;">
        <thead>
            <tr>
                <th><?=utf8ToHtml('Reg')?></th>
                <th><?=utf8ToHtml('NU Portabilidade')?></th>                
                <th><?=(($cddopcao == 'E') ? utf8ToHtml('Banco Folha') : utf8ToHtml('Participante Destino'))?></th>
                <th><?=utf8ToHtml('Data Solicitação')?></th>
                <th><?=utf8ToHtml('Situação')?></th>
                <th><?=utf8ToHtml('Data Retorno')?></th>
                <th><?=utf8ToHtml('Motivo')?></th>
                <th><?=utf8ToHtml('Ações')?></th>
            </tr>
        </thead>
    </table>
    <table>
        <tbody>
        <?
        foreach($solicitacoes as $solicitacao) {
            $qtregist = getByTagName($solicitacao->tags,"qtdesolicitacoes");
            $rownum = getByTagName($solicitacao->tags,"NRROWNUM");
            $nusolicitacao = getByTagName($solicitacao->tags,"NUSOLICITACAO");
            $participante = getByTagName($solicitacao->tags,"PARTICIPANTE");
            $dtsolicitacao = getByTagName($solicitacao->tags,"DTSOLICITACAO");
            $situacao = getByTagName($solicitacao->tags,"SITUACAO");
            $idsituacao = getByTagName($solicitacao->tags,"IDSITUACAO");
            $dtretorno = getByTagName($solicitacao->tags,"DTRETORNO");
            $motivo = getByTagName($solicitacao->tags,"MOTIVO");
            $nrdconta = getByTagName($solicitacao->tags,"nrdconta");
            $dsrowid = getByTagName($solicitacao->tags,"dsrowid");

            ?>
            <tr>
                <td style="width: 25px;"><?=$rownum?></td>
                <td style="width: 137px;"><?=$nusolicitacao?></td>
                <td style="width: 95px;"><?=$participante?></td>
                <td style="width: 67px;"><?=$dtsolicitacao?></td>
                <td style="width: 70px;"><?=$situacao?></td>
                <td style="width: 67px;"><?=$dtretorno?></td>
                <td style="width: 150px;"><?=$motivo?></td>
                <td>
                    <a title="Detalhar" onclick="exibirDetalhe('<?=$dsrowid?>'); return false;" style="cursor: pointer;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                    <?php 
                    if ($cddopcao == 'M') {
                        if (!empty($nrdconta) && $nrdconta > 0) {
                            if ($idsituacao == 1 || $idsituacao == 4) {
                                echo '<a title="Aprovar" onclick="validarAprovacaoPortabilidade(\''.$dsrowid.'\'); return false;" style="cursor: pointer;margin-left:10px;"><img src="'.$UrlImagens.'geral/motor_APROVAR.png"></a>';
                                echo '<a title="Reprovar" onclick="exibirReprovacaoPortabilidade(\''.$dsrowid.'\'); return false;" style="cursor: pointer;margin-left:10px;"><img src="'.$UrlImagens.'geral/motor_REPROVAR.png"></a>';
                                echo '<a title="Devolver" onclick="exibirDevolucaoPortabilidade(\''.$dsrowid.'\'); return false;" style="cursor: pointer;margin-left:10px;"><img src="'.$UrlImagens.'geral/motor_DERIVAR.png"></a>';
                            }
                        } else {
							if ($idsituacao == 1 || $idsituacao == 4) {
                              echo '<a title="Direcionar" onclick="exibirDirecionanamentoPortabilidade(\''.$dsrowid.'\'); return false;" style="cursor: pointer;margin-left:10px;"><img src="'.$UrlImagens.'geral/motor_DERIVAR.png"></a>';
                              echo '<a title="Reprovar" onclick="exibirReprovacaoPortabilidade(\''.$dsrowid.'\'); return false;" style="cursor: pointer;margin-left:10px;"><img src="'.$UrlImagens.'geral/motor_REPROVAR.png"></a>';
						    }
                        }
                    }
                    ?>
                </td>
            </tr>
            <?
        }
        ?>
        </tbody>
    </table>
</div>


<div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>	
        <tr>
            <td>
                <?			
                    if (isset($qtregist) and $qtregist == 0) $pagina = 0;
                    
                    // Se a paginação não está na primeira, exibe botão voltar
                    if ($pagina > 1) { 
                        ?> <a class='paginacaoAnt'><<< Anterior</a> <? 
                    } else {
                        ?> &nbsp; <?
                    }
                ?>
            </td>
            <td>
                <?
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
            <td>
                <?
                    // Se a paginação não está na &uacute;ltima página, exibe botão proximo
                    if ($qtregist > ($pagina * $tamanho_pagina - 1) && $pagina > 0) {
                        ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
                    } else {
                        ?> &nbsp; <?
                    }
                ?>			
            </td>
        </tr>
    </table>
</div>

<script type="text/javascript">

	$('a.paginacaoAnt', '#divTela').unbind('click').bind('click', function() {
		grid.carregar(<? echo "'".$cddopcao."','".($pagina - 1)."'"; ?>);

	});
	$('a.paginacaoProx', '#divTela').unbind('click').bind('click', function() {
		grid.carregar(<? echo "'".$cddopcao."','".($pagina + 1)."'"; ?>);
	});

    $('#divPesquisaRodape', '#divTela').formataRodapePesquisa();
</script> 