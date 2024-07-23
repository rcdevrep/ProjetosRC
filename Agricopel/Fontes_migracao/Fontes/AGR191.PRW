#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

/* SIGAVILLE
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Cliente      ³ Agricopel Com. Derivados de Petróleo Ltda               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa     ³ AGR191           ³ Responsavel ³ Deco                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Gatilho Busca DDD/Tel do cliente para call center       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data        ³ 14/12/05         ³ Implantacao ³                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Deco                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR191()

Local cDDD := ""
Local cTel := ""
Local cRet := ""  

LOCAL aSeg    := GetArea()  

cCliente := M->UA_CLIENTE
cLoja    := M->UA_LOJA

                          	              
cDDD    := POSICIONE("SA1",1,xFilial("SA1")+cCliente+cLoja, "A1_DDD")                           
cTel    := POSICIONE("SA1",1,xFilial("SA1")+cCliente+cLoja, "A1_Tel")                           

cRet := cDDD + "/" + cTel

//GRAVA EMAIL CLIENTE NO CALL-CENTER

If ALLTRIM(SA1->A1_EMAIL) == ''  
   result := .f.  
   Static oDlg
	static obCanc
	Static oBOK
	Static oEmail
	Static cEmail := space(60)
	Static olCliente
	Static olCliente2
	Static olemail
	
	result := MSGBOX("Atenção! Cliente não possui e-mail cadastrado! É importante que o mesmo esteja atualizado para uso das demais rotinas do sistema! Deseja cadastrar?";
   ,"Cadastro e-mail Cliente","YESNO")

    if result == .t.
		cCliente := ''
		cCliente := ALLTRIM(SA1->A1_COD) + ' - ' + ALLTRIM(SA1->A1_LOJA) + ' - ' + ALLTRIM(SA1->A1_NOME)


	  	DEFINE MSDIALOG oDlg TITLE "e-mail Cliente" FROM 000, 000  TO 110, 490 COLORS 0, 16777215 PIXEL

   	 @ 015, 030 MSGET oEmail VAR cEmail SIZE 202, 010 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 031, 152 BUTTON oBOK PROMPT "&OK" SIZE 037, 012 ACTION GRAVA_EMAIL() OF oDlg PIXEL
   	 @ 007, 006 SAY olCliente PROMPT "Cliente :" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 019, 006 SAY olemail PROMPT "e-mail" SIZE 019, 007 OF oDlg COLORS 0, 16777215 PIXEL
   	 @ 031, 194 BUTTON obCanc PROMPT "&Cancelar" SIZE 037, 012 ACTION (oDlg:End()) OF oDlg PIXEL
       @ 007, 029 SAY olCliente2 PROMPT cCliente SIZE 203, 007 OF oDlg COLORS CLR_BLUE, 16777215 PIXEL   
  		ACTIVATE MSDIALOG oDlg
  		
 	EndIf                  
EndIf                     

RESTAREA(aSeg)


Return cRet                   

Static Function GRAVA_EMAIL 
   nTam  := 0 
   nCont := 1
   nTam := LEN(ALLTRIM(cEmail))
   cValid := "N"
   While nCont <= nTam  
           
      If substr(cEmail,nCont,1) == "@"
         cValid := "S"
         exit
      EndIf
      nCont++
   EndDo

   
	If ALLTRIM(cValid) == "N"          
  	  	MsgStop("Informe um e-mail válido!")
   	cEmail := Space(60)
		oEmail :Setfocus()
		return()
	Endif   


	Reclock("SA1",.F.)
     SA1->A1_EMAIL := cEmail
	SA1->(MsUnlock())  
 	Close(oDlg)
Return()