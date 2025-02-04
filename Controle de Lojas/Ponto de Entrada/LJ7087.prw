// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  LJ7087                                                                                                |
 | Desc:  LJ7087 - Customização da definição do tipo emissão da venda, "Cupom ou Nota?"                         |
 |                                                                                                              |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=184780965                                       |
 *--------------------------------------------------------------------------------------------------------------*/

User Function LJ7087()
  Local nRet := 0 //0 = Verifica emissao (padrão) / 1 = Emissão de CF ou NFC-e / 2 = Emissao de nota
  Local cFilNF := SuperGetMV("MV_XFILNF",.F.,"020101")

  Public lNota := .F. 

  If xFilial("SL1") $(cFilNF)
    nRet := 2
    lNota := .T.
    Return nRet
  EndIF 

  If !LjProfile(3) .And. !(IsInCallStack("STIPOSMAIN"))
    nRet := Aviso( "Documento Fiscal de Saida" ,"Qual Documento Fiscal de Saida sera impresso na venda?",{"NFC-e","Nota"})
    lNota := IIF(nRet == 2,.T.,.F.)
  Else
    IIF(SL1->L1_IMPNF,nRet:=2,nRet:=1)
  EndIF

Return nRet
