#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  LJ7001                                                                                               |
 | Desc:  LJ7001 - Valida a gravação do orçamento, é executado após clicar em gravar orçamento.                 |
 |                                                                                                              |
 | Link:  https://tdn.totvs.com/pages/viewpage.action?pageId=232822032                                          |
 *--------------------------------------------------------------------------------------------------------------*/

User Function LJ7001()
  Local aArea    := FWGetArea()
  Local lRet     := .T.
  Local nParTipo := PARAMIXB[1] //(1-Orcamento  2-Venda  3-Pedido) 
  Local nPosProd := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2] // Posicao do campo LR_PRODUTO
  Local nPosEnt  := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ENTREGA"})][2] // Posicao do campo LR_ENTREGA
  Local nX

  If nParTipo != 1
    Return lRet 
  EndIF 

  DBSelectArea("SB1")

  For nX := 1 To Len(aCols)
    If !aCols[nX][Len(aCols[nX])]
      If SB1->(MSSeek(xFilial("SB1") + aCols[nX][nPosProd] ))
        IF AllTrim(SB1->B1_TIPO) != "SV"
          IF aCols[nX][nPosEnt] != '3'
            lRet := .F.
          EndIF 
        EndIF 
      EndIF 
    EndIF 
  Next nX

  If !lRet
    FWAlertWarning("Esse orçamento não poderá ser gravado, existem itens sem reserva.","Itens sem reserva")
  EndIF 

  FWRestArea(aArea)

Return lRet
