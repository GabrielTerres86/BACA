<?php 

	/************************************************************************
	 Fonte: relacionamento.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                Última Alteração:  14/07/2011    
	                                                                  
	 Objetivo  : Mostrar janela principal da rotina de relacionamento
	                                                                  	 
	 Alterações: 01/11/2010 - Incluir campo Data de Digitação na opção
							  Questionário (David).

  			     14/07/2011 - Alterado para layout padrão (Rogerius - DB1).
				 
				 01/12/2015 - Correção de bug de layout na tag <UL><LI> no IE (Dionathan)
				 
			     30/07/2016 - Adicionado classe (SetWindow) - necessaria para navegação com teclado - (Evandro - RKAM)	

			     05/07/2019 - Destacar evento do cooperado - P484.2 - Gabriel Marcos (Mouts).

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Aimaro","");';
		echo '</script>';
		exit();
	}	

     $labelRot = $_POST['labelRot'];	

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
	
?>
<div id="divRelacionamento">
  <?php 
	//Form com os dados para fazer a chamada da geração de PDF	
	include("impressao_form.php"); 
	?>
  <table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
      <td align="center">
        <table border="0" cellpadding="0" cellspacing="0" width="450">
          <tr>
            <td>
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="11">
                    <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                  </td>
                  <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span name="tldatela" id="tldatela" >RELACIONAMENTO</span>
                  </td>
                  <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;">
                      <img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0">
                    </a>
                  </td>
                  <td width="8">
                    <img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21">
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td class="tdConteudoTela" align="center">
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                    <div id="divConteudoOpcao">
                      <div id="divRelacionamentoPrincipal" style="height: 170px;">
                        <form action="" name="frmRelacionamento" id="frmRelacionamento" method="post">
                          <br />
                          <ul id="ulRelacionamento" style="list-style: none;">
                            <li>
                              <input type="image" src="<?php echo $UrlImagens; ?>botoes/eventos_em_andamento.gif" onClick="mostraEventosEmAndamento('');return false;" />
                            </li>
                            <li>
                              <input name="qtandame" type="text" id="qtandame" />

                            </li>

                            <li>
                              <input type="image" src="<?php echo $UrlImagens; ?>botoes/historico_de_participacao.gif" onClick="mostraHistParticipacao();return false;">
                            </li>
                            <li>
                              <input name="qthistor" type="text" id="qthistor"  />
                              <br />
                              <br />
                            </li>

                            <li>
                              <label style="float:left">Pr&eacute;-Inscri&ccedil;&atilde;o:</label>
                              <input type="image" src="<?php echo $UrlImagens; ?>botoes/pendente.gif" onClick="mostraEventosEmAndamento('P');return false;">
                            </li>
                            <li>
                              <input name="qtpenden" type="text" id="qtpenden" />
                            </li>

                            <li>
                              <input type="image" src="<?php echo $UrlImagens; ?>botoes/confirmada.gif" onClick="mostraEventosEmAndamento('C');return false;"  >
                            </li>
                            <li>
                              <input name="qtconfir" type="text" id="qtconfir" />
                              <br />
                              <br />
                            </li>

                            <li>
                              <input type="image" src="<?php echo $UrlImagens; ?>botoes/questionario.gif" <?php if (!in_array("A",$opcoesTela)) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="mostraQuestionario();return false;"'; } ?>>
                            </li>
                            <li>
                              <input name="dtinique" type="text" id="dtinique" />
                              <input name="dtfimque" type="text" id="dtfimque" />
                            </li>

                            <li>
                              <br>
                              <input type="image" src="<?php echo $UrlImagens; ?>botoes/cargos.gif" name="btnCargos" id="btnCargos" value="Cargos" onClick="mostraCargos();return false;">
                            </li>
                          </ul>
                        </form>
                      </div>

                      <div id="divRelacionamentoQuestionario">
                        <form action="" name="frmRelacionamentoQuestionario" id="frmRelacionamentoQuestionario" class="formulario" method="post">
                          <fieldset>
                            <legend>Questionário</legend>

                            <label for="dtinique">Question&aacute;rio Entregue:</label>
                            <input name="dtinique" type="text" class="campo" id="dtinique" style="width: 70px; text-align: center">

                              <br />

                              <label for="dtfimque">Question&aacute;rio Devolvido:</label>
                              <input name="dtfimque" type="text" class="campo" id="dtfimque" style="width: 70px; text-align: center">

                                <label for="dtcadqst">Data de Digita&ccedil;&atilde;o:</label>
                                <input name="dtcadqst" type="text" class="campoTelaSemBorda" id="dtcadqst" style="width: 70px; text-align: center" disabled="">
													</fieldset>

                          <div id="divBotoes">
                            <input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divRelacionamentoPrincipal').css('display','block');$('#divRelacionamentoQuestionario').css('display','none');return false;">
                            <input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="alterarDatasQuestionario();return false;">
                          </div>

                        </form>
                      </div>
                    </div>
                    <div id="divOpcoesDaOpcao1"></div>
                    <div id="divOpcoesDaOpcao2"></div>
                    <div id="divOpcoesDaOpcao3"></div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</div>
<script type="text/javascript">

  // Mostra div da rotina
  mostraRotina();

  // Esconde mensagem de aguardo
  hideMsgAguardo();

  acessaOpcaoPrincipal();
</script>