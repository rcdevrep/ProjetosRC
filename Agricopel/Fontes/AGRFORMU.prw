#Include "PROTHEUS.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} AGRFORMU                                    
Description Programa para Execução de Fórmulas                                                                                                                                                            
@author Spiller                                              
@since 01/11/2017                                                   
/*/                                                             
//--------------------------------------------------------------
User Function AGRFORMU()                                      
Static oDlg
Static oButton1
Static oGet1
Static cGet1 := SPACE(150)
Static oSay1

  DEFINE MSDIALOG oDlg TITLE "Executar Programas" FROM 000, 000  TO 100, 330 COLORS 0, 16777215 PIXEL

    @ 015, 006 MSGET oGet1 VAR cGet1 SIZE 153, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 004, 006 SAY oSay1 PROMPT "Programa" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 030, 118 BUTTON oButton1 PROMPT "Confirmar" SIZE 040, 011 OF oDlg ACTION Executar(cGet1) PIXEL
    
  ACTIVATE MSDIALOG oDlg CENTERED

Return      

Static Function Executar(xGet1)    

	&(xGet1)

Return