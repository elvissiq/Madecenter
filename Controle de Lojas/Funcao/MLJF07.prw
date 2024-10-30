//Bibliotecas
#Include 'Protheus.ch'
#Include "TOPCONN.ch"
#Include 'FWMVCDef.ch'

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF07
FUNÇÃO MLJF07 - Reimpressão de comprovante retira
@VERSION PROTHEUS 12
@SINCE 30/10/2024
/*/
//----------------------------------------------------------------------

User Function MLJF07()
  Local aPARAMIXB := {}
  
  IF LjProfile(8)
    If ExistBlock("SCRPED")
      ExecBlock("SCRPED" ,.F.,.F., aPARAMIXB )
    EndIF
  EndIF

Return
