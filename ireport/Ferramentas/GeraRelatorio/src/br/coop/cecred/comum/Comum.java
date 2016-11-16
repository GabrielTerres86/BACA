package br.coop.cecred.comum;

/**
 * Classe para concentrar métodos comuns a toda as operações de arquivos e relatórios.
 * @author Petter - Supero Tecnologia
 * @since  Março/2013
 */
public class Comum {
    private String gerarPDF;
        
     /**
     * Método de retorno do status da ação de gerar arquivo PDF.
     * @return Retorna status do processo
     */
    public String getGerarPDF() {
        return gerarPDF;
    }

    /**
     * Método de definição do status da ação de gerar arquivo PDF.
     * @param gerarPDF Status do processo
     */
    public void setGerarPDF(String gerarPDF) {
        this.gerarPDF = gerarPDF;
    }
}
