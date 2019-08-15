<?php
/* 
 * Classe Responsavel da requisicao REST da analise
 * 
 * @autor: Lucas Reinert
 * @alteracoes:
 *              28/06/2018 - Incluindo novo parametro para recebimento do motor de crédito
 *                           Fluxo atraso (liquidOpCredAtraso - inopeatr)
 *                           P450 - Diego Simas - AMcom
 *
 */
require_once('../class/class_rest_server_json.php');
class RestAnalise extends RestServerJson{
    
    private $aParamsRequired;
    
    public function __construct(){
        $this->aParamsRequired = array('protocolo','resultadoAnaliseRegra');
        $this->setRequisicaoAutenticada(false);
    }
    
    public function __destruct(){
        unset($this->aParamsRequired);
    }
    
    /**
     * Método responsavel por enviar a mensagem de resposta a requisicao
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */
    private function processaRetorno($status, $mensagemDetalhe, $numeroTransacao = '00000000000000000000', $cdcritic = '0', $dscritic = ''){
        $aRetorno = array();
        $aRetorno['status']      = $status;
        $aRetorno['nrtransacao'] = $numeroTransacao;
        $aRetorno['cdcritic']    = $cdcritic;
        $aRetorno['dscritic']    = $dscritic;
        $aRetorno['msg_detalhe'] = $mensagemDetalhe;
        // Setando o codigo do status no Header da resposta
        header("Cache-Control: no-cache, must-revalidate");
		    header("Expires: 0");
		    header('Content-Type: ' . RestFormat::$aRestFormat[$this->getTypeFormato()]);
        header('Status-Code: '.$status, true, $status);
        // Enviando a resposta para o servico
        return $this->processaRetornoFormato($aRetorno);
    }
    
    /**
     * Método responsavel por enviar a mensagem de Exception
     * @param String Status
     * @param String Mensagem de detalhe
     * @return boolean
     */
    private function processaRetornoErro($status, $mensagemDetalhe){
        // Grava o erro no arquivo TEXTO
        $xml  = "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <dsmessag>".$mensagemDetalhe."</dsmessag>";
        $xml .= "   <dsrequis>".$this->getFileContents()."</dsrequis>";
        $xml .= " </Dados>";
        $xml .= "</Root>";
        mensageria($xml, "WEBS0001", "WEBS0001_GRAVA_REQUISICAO_ERRO", 0, 0, 0, 5, 0, "</Root>");
        // Retorna a mensagem de critica
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe);
    }
    
    /**
     * Método responsavel por enviar de sucesso
     * @param String $status
     * @param String $mensagemDetalhe
     * @param String $numeroTransacao
     * @param String $cdcritic
     * @param String $dscritic
     * @return boolean
     */
    private function processaRetornoSucesso($status,$mensagemDetalhe,$numeroTransacao,$cdcritic,$dscritic){
        return $this->processaRetorno((string) $status,(string) $mensagemDetalhe,(string) $numeroTransacao,(string) $cdcritic,(string) $dscritic);
    }

    /**
     * Valida se todos os parametros recebidos estão corretos
     * @param Object $oDados
     * @return boolean
     */
    private function validaParametrosRecebidos($oDados){
        // Condicao para verificar se eh um objeto
        if (!is_object($oDados)){
            $this->processaRetornoErro(412,'Resultado da Analise Automatica nao foi atualizado, parametros incorretos[o].');
            return false;
        }
		
        // Verifica se todos os parametros foram recebidos
        foreach ($this->aParamsRequired as $sPametro){
			  if (!array_key_exists($sPametro,get_object_vars($oDados))){
                $this->processaRetornoErro(412,'Resultado da Analise Automatica nao foi atualizado, parametros incorretos[r].');
                return false;
            }
        }
        return true;
    }
    
    /**
     * Processa os dados da Requisicao
     */
    public function processaRequisicao(){
        try{
            $this->setMetodoRequisitado('POST');
            
            // Valida os dados da requisicao
            if (!$this->validaRequisicao()){
                return false;
            }

            // Busca os dados da requisicao
            $oDados = $this->getDados();

            // Valida se veio todos os parametros obrigatorios
            if (!$this->validaParametrosRecebidos($oDados)){
                return false;            
            }
            
            $segueFluxoAtacado = (isset($oDados->indicadoresGeradosRegra->segueFluxoAtacado))? $oDados->indicadoresGeradosRegra->segueFluxoAtacado : FALSE;
            
			      // Processa a informacao do banco de dados        
			      $xml  = "<Root>";
			      $xml .= " <Dados>";
			      $xml .= "   <cdorigem>9</cdorigem>";
			      $xml .= "   <dsprotoc>".$oDados->protocolo."</dsprotoc>";
                  $xml .= "   <nrtransa>0</nrtransa>";
			      $xml .= "   <dsresana>".$oDados->resultadoAnaliseRegra."</dsresana>";
			      $xml .= "   <indrisco>".$oDados->indicadoresGeradosRegra->nivelRisco."</indrisco>";
			      $xml .= "   <nrnotrat>".$oDados->indicadoresGeradosRegra->notaRating."</nrnotrat>";
			      $xml .= "   <nrinfcad>".$oDados->indicadoresGeradosRegra->informacaoCadastral."</nrinfcad>";
			      $xml .= "   <nrliquid>".$oDados->indicadoresGeradosRegra->liquidez."</nrliquid>";
			      $xml .= "   <nrgarope>".$oDados->indicadoresGeradosRegra->garantia."</nrgarope>";
                  $xml .= "   <inopeatr>".$oDados->indicadoresGeradosRegra->liquidOpCredAtraso."</inopeatr>";
			      $xml .= "   <nrparlvr>".$oDados->indicadoresGeradosRegra->patrimonioPessoalLivre."</nrparlvr>";
			      $xml .= "   <nrperger>".$oDados->indicadoresGeradosRegra->percepcaoGeralEmpresa."</nrperger>";
                  $xml .= "   <desscore>".$oDados->indicadoresGeradosRegra->descricaoScoreBVS."</desscore>";
                  $xml .= "   <datscore>".$oDados->indicadoresGeradosRegra->dataScoreBVS."</datscore>";
			      $xml .= "   <dsrequis>".$this->getFileContents()."</dsrequis>";
			      $xml .= "   <namehost>".$this->getNameHost()."</namehost>";
            $xml .= "   <idfluata>".$segueFluxoAtacado."</idfluata>";
			      $xml .= " </Dados>";
			      $xml .= "</Root>";
			      $sXmlResult = mensageria($xml, "WEBS0001", "WEBS0001_ANALISE_MOTOR", 0, 0, 0, 5, 0, "</Root>");
            $oRetorno   = simplexml_load_string($sXmlResult);
            
            // Vamos verificar se veio retorno 
            if ((!isset($oRetorno->inf->status)) || ($oRetorno->inf->status == 0) || ($oRetorno->inf->status == '')){
                $this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.');
                return false;
            }            
            // Retorna a resposta para o servico
            $this->processaRetornoSucesso($oRetorno->inf->status,
                                          $oRetorno->inf->msg_detalhe,
                                          $oRetorno->inf->nrtransacao,
                                          $oRetorno->inf->cdcritic,
                                          $oRetorno->inf->dscritic);
        } catch(RestException $oException){
            $this->processaRetornoErro($oException->getCode(), $oException->getMessage());
            return false;            
        } catch (Exception $oException){
            $this->processaRetornoErro(500,'Ocorreu um erro interno no sistema.');
            return false;
        }
        return true;
    }
}
?>