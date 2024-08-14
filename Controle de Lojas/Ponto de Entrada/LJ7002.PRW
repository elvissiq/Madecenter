#Include 'Protheus.ch'
/*/
  @param
  @return Não retorna nada
  @author Totvs Nordeste (Elvis Siqueira)
  @owner Totvs S/A
  @version Protheus 10, Protheus 11,Protheus 12
  @since 07/02/2024
  @sample
  			Ponto de Entrada chamado depois da gravação de todos os dados 
        e da impressão do cupom fiscal na Venda Assistida e após o processamento do Job LjGrvBatch
  @obs
  @project
  @menu 
  @history
  31/01/2024 - Desenvolvimento da Rotina.
/*/

User Function LJ7002()
  Local aArea  := FWGetArea()
  Local cOpcao := cValToChar(ParamIxB[1])
  Local lGrvBatch := IIF(ParamIxB[3] == 2,.T.,.F.)

  If cOpcao == "1" .AND. !(lGrvBatch)
        
        IF FWAlertNoYes("Imprimir orçamento ?","Impressão")
          u_zROrcVen()
        EndIF

        RecLock("SL1",.F.)
          SL1->L1_NOMCLI := M->LQ_NOMCLI
        SL1->(MsUnLock())
      
  EndIf

  FWRestArea(aArea)
  
Return
