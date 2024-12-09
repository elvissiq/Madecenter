#Include 'Protheus.ch'
#Include "TOPCONN.ch"

/*/
/*-----------------------------------------------------------------------
  Fun��o: L010RETNG

  L010RETNG - Altera��o de dados da tela da Condi��o negociada, 
              Venda e Balc�o.

  Esse ponto de entrada permite a altera��o do dados da tela da 
  Condi��o Negociada, Venda Balc�o.

Retorno:
  AretNg(Vetor)

--------------------------------------------------------------------------
  @history
  13/11/2024 - Desenvolvimento da Rotina.
/*/

User Function L010RETNG()
  Local aArea   := FWGetArea()
  Local aRetNeg := ParamIxB
  
  aRetNeg[1][1] := 1                         // (N) Tipo de C�lculo, sendo: 1 - Simples, 2 - S�rie de Pagamentos
  aRetNeg[1][2] := "0"                       // (C) String de 4 d�gitos, que indica que tipo de c�lculo est� habilitado ou n�o, para sele��o, sendo "0" - desabilita e "1" - habilita
  aRetNeg[2][1] := aRetNeg[2][1]             // (L) Op��o "Utiliza Financiadora" est� selecionada
  aRetNeg[2][2] := aRetNeg[2][2]             // "0" indica que a op��o "Utiliza Financiadora" N�O estar� aberta para sele��o ( enable) e "1" indica que a op��o "Utiliza Financiadora" estar� aberta para sele��o ( enable)
  aRetNeg[3][1] := aRetNeg[3][1]             // (C) Nome da administradora financeira
  aRetNeg[3][2] := aRetNeg[3][2]             // "0" indica que o combo de sele��o da "Administradora" N�O estar� aberto para sele��o ( enable) e "1" indica que o combo de sele��o da "Administradora" estar� aberto para sele��o ( enable)
  aRetNeg[4][1] := DaySum(aRetNeg[4][1],30)  // (D) Data da primeira parcela
  aRetNeg[4][2] := "0"                       // "0" indica que a linha "Primeira parcela" estar� aberta para edi��o ( enable), "1" indica que  a linha "Primeira parcela" n�o estar� aberta para edi��o ( disable) e "2" indica que a linha "Primeira parcela" n�o ser� apresentada na tela
  aRetNeg[5][1] := aRetNeg[5][1]             // (N) Valor de entrada
  aRetNeg[5][2] := "0"                       // "0" indica que a linha "Entrada" estar� aberta para edi��o ( enable), "1" indica que a linha "Entrada" n�o estar� aberta para edi��o ( disable) e "2" indica que a linha "Entrada" n�o ser� apresentada na tela
  aRetNeg[6][1] := aRetNeg[6][1]             // (N) Valor da taxa de juros
  aRetNeg[6][2] := "0"                       // "0" indica que a linha "Taxa de Juros" estar� aberta para edi��o ( enable), "1" indica que a linha "Taxa de Juros" n�o estar� aberta para edi��o ( disable) e "2" indica que a linha "Taxa de Juros" n�o ser� apresentada na tela
  aRetNeg[7][1] := aRetNeg[7][1]             // (N) N�mero de parcelas
  aRetNeg[7][2] := aRetNeg[7][2]             // "0" Indica que a linha "Parcelas" estar� aberta para edi��o ( enable), "1" indica que a linha "Parcelas" n�o estar� aberta para edi��o ( disable) e "2" indica que a linha "Parcelas" n�o ser� apresentada na tela
  aRetNeg[8][1] := aRetNeg[8][1]             // (N) N�mero de dias de intervalos entre as parcelas
  aRetNeg[8][2] := aRetNeg[8][2]             // "0" indica que a linha "Intervalo" estar� aberta para edi��o ( enable), "1" indica que a linha "Intervalo" n�o estar� aberta para edi��o ( disable) e "2" indica que a linha "Intervalo" n�o ser� apresentada na tela
  
  FWRestArea(aArea)

Return aRetNeg
