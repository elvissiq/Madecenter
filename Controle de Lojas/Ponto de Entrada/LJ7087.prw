// BIBLIOTECAS NECESS�RIAS
#Include "TOTVS.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  LJ7087                                                                                                |
 | Desc:  LJ7087 - Customiza��o da defini��o do tipo emiss�o da venda, "Cupom ou Nota?"                         |
 |                                                                                                              |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=184780965                                       |
 *--------------------------------------------------------------------------------------------------------------*/

User Function LJ7087()
    Local nRet := 0 //0 = Verifica emissao (padr�o) / 1 = Emiss�o de CF ou NFC-e / 2 = Emissao de nota

    If !LjProfile(3)
      nRet := Aviso( "Documento Fiscal de Saida" ,"Qual Documento Fiscal de Saida sera impresso na venda?",{"NFC-e","Nota"})
    Else
      IF(SL1->L1_IMPNF,nRet:=2,nRet:=1)
    EndIF

Return nRet
